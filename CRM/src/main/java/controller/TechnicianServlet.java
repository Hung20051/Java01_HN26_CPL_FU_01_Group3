    package controller;

    import dao.*;
    import model.*;
    import jakarta.servlet.ServletException;
    import jakarta.servlet.annotation.WebServlet;
    import jakarta.servlet.http.*;

    import java.io.IOException;
    import java.math.BigDecimal;
    import java.math.RoundingMode;
    import java.time.LocalDate;
    import java.util.*;


    public class TechnicianServlet extends HttpServlet {

        private final ServiceRequestDAO srDAO   = new ServiceRequestDAO();
        private final WorkTaskDAO       wtDAO   = new WorkTaskDAO();
        private final RepairReportDAO   rrDAO   = new RepairReportDAO();
        private final InvoiceDAO        invDAO  = new InvoiceDAO();
        private final PartDAO           partDAO = new PartDAO();
        private final TechnicianWorkloadDAO twDAO = new TechnicianWorkloadDAO();

        private static final int PAGE_SIZE = 10;
        private static final BigDecimal TAX = new BigDecimal("0.10");

        // ── Shared auth guard ──────────────────────────────────────────────
        private User getAuth(HttpServletRequest req, HttpServletResponse resp) throws IOException {
            User me = (User) req.getSession().getAttribute("user");
            if (me == null || !"TECHNICIAN".equals(me.getRoleName())) {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return null;
            }
            return me;
        }

        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp)
                throws ServletException, IOException {

            User me = getAuth(req, resp);
            if (me == null) return;

            String path   = req.getServletPath();
            String action = req.getParameter("action");
            String ctx    = req.getContextPath();

            try {
                // ══════════════════════════════════════════════════════════
                //  /techTasks  — Task management
                // ══════════════════════════════════════════════════════════
                if ("/techTasks".equals(path)) {

                    // Detail view of 1 task
                    if ("detail".equals(action)) {
                        int taskId = Integer.parseInt(req.getParameter("id"));
                        WorkTask task = getTaskForTechnician(taskId, me.getId());
                        if (task == null) {
                            req.getSession().setAttribute("flash_error", "Task not found.");
                            resp.sendRedirect(ctx + "/techTasks");
                            return;
                        }
                        ServiceRequest sr = srDAO.getById(task.getRequestId());
                        RepairReport   rr = rrDAO.findByWorkTaskId(taskId);

                        // Parts available in warehouse
                        List<PartType> availableParts = partDAO.findAvailableTypes();

                        // All tasks for this SR (to show co-technicians)
                        List<WorkTask> allTasks = wtDAO.findByRequestId(task.getRequestId());

                        req.setAttribute("task",           task);
                        req.setAttribute("sr",             sr);
                        req.setAttribute("report",         rr);
                        req.setAttribute("availableParts", availableParts);
                        req.setAttribute("allTasks",       allTasks);
                        req.getRequestDispatcher("/techTaskDetail.jsp").forward(req, resp);
                        return;
                    }

                    // List view (default)
                    String filterStatus = req.getParameter("status");
                    int page = parsePage(req);

                    List<WorkTask> tasks = getTasksForTechnician(me.getId(), filterStatus, page, PAGE_SIZE);
                    int total      = countTasksForTechnician(me.getId(), filterStatus);
                    int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

                    // Stats
                    Map<String, Integer> stats = getTaskStats(me.getId());

                    req.setAttribute("tasks",        tasks);
                    req.setAttribute("total",        total);
                    req.setAttribute("page",         page);
                    req.setAttribute("totalPages",   totalPages);
                    req.setAttribute("filterStatus", filterStatus);
                    req.setAttribute("stats",        stats);
                    req.getRequestDispatcher("/techTasks.jsp").forward(req, resp);
                    return;
                }

                // ══════════════════════════════════════════════════════════
                //  /techReports  — Report history
                // ══════════════════════════════════════════════════════════
                if ("/techReports".equals(path)) {

                    // Detail view
                    if ("detail".equals(action)) {
                        int rId = Integer.parseInt(req.getParameter("id"));
                        RepairReport rr = rrDAO.findById(rId);
                        if (rr == null || rr.getTechnicianId() != me.getId()) {
                            req.getSession().setAttribute("flash_error", "Report not found.");
                            resp.sendRedirect(ctx + "/techReports");
                            return;
                        }
                        req.setAttribute("report", rr);
                        req.getRequestDispatcher("/techReportDetail.jsp").forward(req, resp);
                        return;
                    }

                    // List view
                    String filterStatus = req.getParameter("status");
                    int page = parsePage(req);

                    List<RepairReport> reports = rrDAO.findByTechnicianId(me.getId(), filterStatus, page, PAGE_SIZE);
                    int total      = rrDAO.countByTechnicianId(me.getId(), filterStatus);
                    int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
                    Map<String, Integer> stats = rrDAO.getStatsByTechnician(me.getId());

                    req.setAttribute("reports",      reports);
                    req.setAttribute("total",        total);
                    req.setAttribute("page",         page);
                    req.setAttribute("totalPages",   totalPages);
                    req.setAttribute("filterStatus", filterStatus);
                    req.setAttribute("stats",        stats);
                    req.getRequestDispatcher("/techReports.jsp").forward(req, resp);
                }

            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("flash_error", "Error: " + e.getMessage());
                resp.sendRedirect(ctx + (("/techReports".equals(path)) ? "/techReports" : "/techTasks"));
            }
        }

        @Override
        protected void doPost(HttpServletRequest req, HttpServletResponse resp)
                throws ServletException, IOException {
            req.setCharacterEncoding("UTF-8");

            User me = getAuth(req, resp);
            if (me == null) return;

            String action = req.getParameter("action");
            String ctx    = req.getContextPath();

            try {
                // ── saveReport: lưu/cập nhật báo cáo (DRAFT) ─────────────
                if ("saveReport".equals(action)) {
                    int taskId = Integer.parseInt(req.getParameter("taskId"));
                    WorkTask task = getTaskForTechnician(taskId, me.getId());
                    if (task == null) {
                        setFlashErr(req, "Task not found.");
                        resp.sendRedirect(ctx + "/techTasks");
                        return;
                    }

                    String diagnosis  = req.getParameter("diagnosis");
                    String workDone   = req.getParameter("workDone");
                    String laborStr   = req.getParameter("laborCost");
                    BigDecimal labor  = parseBD(laborStr);

                    // Parse parts
                    String[] partIds   = safeArray(req.getParameterValues("partTypeId"));
                    String[] partQtys  = safeArray(req.getParameterValues("partQty"));

                    // Build parts list & validate stock
                    List<RepairReportPart> parts = new ArrayList<>();
                    for (int i = 0; i < partIds.length; i++) {
                        int ptId = Integer.parseInt(partIds[i]);
                        int qty  = Integer.parseInt(partQtys[i]);
                        if (qty <= 0) continue;

                        PartType pt = partDAO.findTypeById(ptId);
                        if (pt == null) continue;
                        if (pt.getAvailableUnits() < qty) {
                            setFlashErr(req, "Not enough stock for: " + pt.getName()
                                + " (available: " + pt.getAvailableUnits() + ")");
                            resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                            return;
                        }

                        RepairReportPart p = new RepairReportPart();
                        p.setPartTypeId(ptId);
                        p.setPartName(pt.getName());
                        p.setQuantity(qty);
                        BigDecimal up = BigDecimal.valueOf(pt.getUnitPrice());
                        p.setUnitPrice(up);
                        p.setTotalPrice(up.multiply(BigDecimal.valueOf(qty)));
                        parts.add(p);
                    }

                    // Upsert report
                    RepairReport existing = rrDAO.findByWorkTaskId(taskId);
                    int reportId;
                    if (existing == null) {
                        RepairReport rr = new RepairReport();
                        rr.setWorkTaskId(taskId);
                        rr.setServiceRequestId(task.getRequestId());
                        rr.setTechnicianId(me.getId());
                        rr.setDiagnosis(diagnosis);
                        rr.setWorkDone(workDone);
                        rr.setLaborCost(labor);
                        reportId = rrDAO.create(rr);
                    } else {
                        if ("SUBMITTED".equals(existing.getStatus())) {
                            setFlashErr(req, "Report already submitted, cannot edit.");
                            resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                            return;
                        }
                        existing.setDiagnosis(diagnosis);
                        existing.setWorkDone(workDone);
                        existing.setLaborCost(labor);
                        rrDAO.update(existing);
                        reportId = existing.getId();
                    }

                    // Save parts
                    rrDAO.saveParts(reportId, parts);

                    setFlashOk(req, "Report saved as draft.");
                    resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                    return;
                }

                // ── submitReport: submit + deduct parts + tạo invoice nếu xong ─
                if ("submitReport".equals(action)) {
                    int taskId = Integer.parseInt(req.getParameter("taskId"));
                    WorkTask task = getTaskForTechnician(taskId, me.getId());
                    if (task == null) {
                        setFlashErr(req, "Task not found.");
                        resp.sendRedirect(ctx + "/techTasks");
                        return;
                    }

                    RepairReport rr = rrDAO.findByWorkTaskId(taskId);
                    if (rr == null) {
                        setFlashErr(req, "Please save the report first before submitting.");
                        resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                        return;
                    }
                    if ("SUBMITTED".equals(rr.getStatus())) {
                        setFlashErr(req, "Report already submitted.");
                        resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                        return;
                    }

                    // 1. Trừ parts từ kho (deduct AVAILABLE units)
                    ServiceRequest sr = srDAO.getById(rr.getServiceRequestId());
                    if (rr.getParts() != null) {
                        for (RepairReportPart p : rr.getParts()) {
                            int deleted = partDAO.deleteAvailableUnits(p.getPartTypeId(), p.getQuantity());
                            if (deleted < p.getQuantity()) {
                                setFlashErr(req, "Insufficient stock for part: " + p.getPartName());
                                resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                                return;
                            }
                        }
                    }

                    // 2. Submit report
                    rrDAO.submit(rr.getId(), me.getId());

                    // 3. Update work_task status → Completed
                    updateTaskStatus(taskId, "Completed");

                    // 4. Decrement workload
                    twDAO.ensureExists(me.getId());
                    twDAO.decrement(me.getId(), 1);

                    // 5. Kiểm tra tất cả tasks đã submitted chưa
                    boolean allDone = rrDAO.allTasksSubmitted(rr.getServiceRequestId());
                    if (allDone) {
                        // 6. Tạo hóa đơn tổng hợp
                        createConsolidatedInvoice(rr.getServiceRequestId(), sr, me.getId());

                        // 7. Mark SR completed
                        markSRCompleted(rr.getServiceRequestId());

                        setFlashOk(req, "Report submitted! All technicians done — invoice sent to customer.");
                    } else {
                        setFlashOk(req, "Report submitted successfully. Waiting for other technicians.");
                    }

                    resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                    return;
                }

                // ── updateTaskStatus: In Progress ─────────────────────────
                if ("startTask".equals(action)) {
                    int taskId = Integer.parseInt(req.getParameter("taskId"));
                    WorkTask task = getTaskForTechnician(taskId, me.getId());
                    if (task != null && "Assigned".equals(task.getStatus())) {
                        updateTaskStatus(taskId, "In Progress");
                        setFlashOk(req, "Task marked as In Progress.");
                    }
                    resp.sendRedirect(ctx + "/techTasks?action=detail&id=" + taskId);
                    return;
                }

            } catch (Exception e) {
                e.printStackTrace();
                setFlashErr(req, "Error: " + e.getMessage());
            }

            resp.sendRedirect(ctx + "/techTasks");
        }

        // ══════════════════════════════════════════════════════════════════
        //  INVOICE CREATION
        // ══════════════════════════════════════════════════════════════════
        private void createConsolidatedInvoice(int srId, ServiceRequest sr, int creatorId)
                throws Exception {

            List<RepairReport> reports = rrDAO.findByServiceRequestId(srId);
            boolean isWarranty = "WARRANTY".equals(sr.getContractType());

            // Build invoice items
            List<InvoiceItem> items = new ArrayList<>();
            BigDecimal subtotal = BigDecimal.ZERO;

            for (RepairReport rr : reports) {
                // Tiền công từng technician (luôn tính)
                if (rr.getLaborCost() != null && rr.getLaborCost().compareTo(BigDecimal.ZERO) > 0) {
                    InvoiceItem labor = new InvoiceItem();
                    labor.setItemName("Labor cost — " + rr.getTechnicianName()
                        + " (" + rr.getReportCode() + ")");
                    labor.setItemType("SERVICE");
                    labor.setQuantity(1);
                    labor.setUnitPrice(rr.getLaborCost());
                    labor.setTotalPrice(rr.getLaborCost());
                    items.add(labor);
                    subtotal = subtotal.add(rr.getLaborCost());
                }

                // Parts — chỉ tính tiền nếu là MAINTENANCE
                if (!isWarranty && rr.getParts() != null) {
                    for (RepairReportPart p : rr.getParts()) {
                        InvoiceItem pi = new InvoiceItem();
                        pi.setItemName(p.getPartName() + " x" + p.getQuantity());
                        pi.setItemType("PART");
                        pi.setQuantity(p.getQuantity());
                        pi.setUnitPrice(p.getUnitPrice());
                        pi.setTotalPrice(p.getTotalPrice());
                        pi.setRefItemId(p.getPartTypeId());
                        items.add(pi);
                        subtotal = subtotal.add(p.getTotalPrice());
                    }
                }
            }

            BigDecimal taxAmount = subtotal.multiply(TAX).setScale(2, RoundingMode.HALF_UP);
            BigDecimal total     = subtotal.add(taxAmount);

            // Create invoice header
            int invoiceId = createInvoice(sr, subtotal, taxAmount, total, creatorId, items);

            // Link reports → invoice
            for (RepairReport rr : reports) {
                rrDAO.setInvoiceId(rr.getId(), invoiceId);
            }
        }

        private int createInvoice(ServiceRequest sr,
                                   BigDecimal subtotal, BigDecimal tax, BigDecimal total,
                                   int creatorId, List<InvoiceItem> items) throws Exception {

            String sql = """
                INSERT INTO invoices
                  (invoice_code, customer_id, service_request_id, invoice_type,
                   subtotal, tax_percent, tax_amount, total_amount,
                   status, due_date, notes, created_by)
                VALUES (?,?,?,'REPAIR',?,10.00,?,?,'UNPAID',?,?,?)
                """;

            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, generateInvoiceCode(con));
                ps.setInt   (2, sr.getCustomerId());
                ps.setInt   (3, sr.getId());
                ps.setBigDecimal(4, subtotal);
                ps.setBigDecimal(5, tax);
                ps.setBigDecimal(6, total);
                ps.setString(7, LocalDate.now().plusDays(30).toString());
                ps.setString(8, "Repair invoice for " + sr.getRequestCode()
                    + " — " + ("WARRANTY".equals(sr.getContractType())
                        ? "WARRANTY (parts free, labor only)"
                        : "MAINTENANCE (parts + labor)"));
                ps.setInt(9, creatorId);
                ps.executeUpdate();

                int invoiceId;
                try (var rs = ps.getGeneratedKeys()) {
                    invoiceId = rs.next() ? rs.getInt(1) : -1;
                }

                // Insert items
                String ins = """
                    INSERT INTO invoice_items
                      (invoice_id, item_name, item_type, quantity, unit_price, total_price, ref_item_id)
                    VALUES (?,?,?,?,?,?,?)
                    """;
                try (var ps2 = con.prepareStatement(ins)) {
                    for (InvoiceItem it : items) {
                        ps2.setInt(1, invoiceId);
                        ps2.setString(2, it.getItemName());
                        ps2.setString(3, it.getItemType());
                        ps2.setInt   (4, it.getQuantity());
                        ps2.setBigDecimal(5, it.getUnitPrice());
                        ps2.setBigDecimal(6, it.getTotalPrice());
                        ps2.setInt(7, it.getRefItemId());
                        ps2.addBatch();
                    }
                    ps2.executeBatch();
                }
                return invoiceId;
            }
        }

        private String generateInvoiceCode(java.sql.Connection con) throws Exception {
            int year = java.time.Year.now().getValue();
            String sql = "SELECT COUNT(*) FROM invoices WHERE YEAR(created_at)=?";
            try (var ps = con.prepareStatement(sql)) {
                ps.setInt(1, year);
                try (var rs = ps.executeQuery()) {
                    int seq = rs.next() ? rs.getInt(1) + 1 : 1;
                    return String.format("INV%d-%03d", year, seq);
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════
        //  DB HELPERS
        // ══════════════════════════════════════════════════════════════════
        private WorkTask getTaskForTechnician(int taskId, int techId) throws Exception {
            String sql = "SELECT wt.*, u.full_name AS technician_name "
                       + "FROM work_tasks wt JOIN users u ON u.id=wt.technician_id "
                       + "WHERE wt.id=? AND wt.technician_id=?";
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, techId);
                try (var rs = ps.executeQuery()) {
                    if (!rs.next()) return null;
                    WorkTask t = new WorkTask();
                    t.setId(rs.getInt("id"));
                    int rid = rs.getInt("request_id");
                    if (!rs.wasNull()) t.setRequestId(rid);
                    t.setTechnicianId(rs.getInt("technician_id"));
                    t.setTaskType(rs.getString("task_type"));
                    t.setTaskDetails(rs.getString("task_details"));
                    t.setStatus(rs.getString("status"));
                    java.sql.Timestamp cat = rs.getTimestamp("created_at");
                    if (cat != null) t.setCreatedAt(cat.toLocalDateTime());
                    try { t.setTechnicianName(rs.getString("technician_name")); } catch (Exception ignored) {}
                    return t;
                }
            }
        }

        private List<WorkTask> getTasksForTechnician(int techId, String status,
                                                      int page, int pageSize) throws Exception {
            StringBuilder sql = new StringBuilder(
                "SELECT wt.*, u.full_name AS technician_name, "
              + "sr.request_code, sr.title AS sr_title, sr.priority AS sr_priority, "
              + "sr.status AS sr_status, c.contract_type "
              + "FROM work_tasks wt "
              + "JOIN users u ON u.id = wt.technician_id "
              + "LEFT JOIN service_requests sr ON sr.id = wt.request_id "
              + "LEFT JOIN contracts c ON c.id = sr.contract_id "
              + "WHERE wt.technician_id = ?"
            );
            List<Object> params = new ArrayList<>();
            params.add(techId);
            if (status != null && !status.isEmpty()) {
                sql.append(" AND wt.status = ?");
                params.add(status);
            }
            sql.append(" ORDER BY wt.created_at DESC LIMIT ? OFFSET ?");
            params.add(pageSize);
            params.add((page - 1) * pageSize);

            List<WorkTask> list = new ArrayList<>();
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (var rs = ps.executeQuery()) {
                    while (rs.next()) {
                        WorkTask t = new WorkTask();
                        t.setId(rs.getInt("id"));
                        int rid = rs.getInt("request_id");
                        if (!rs.wasNull()) t.setRequestId(rid);
                        t.setTechnicianId(rs.getInt("technician_id"));
                        t.setTaskType(rs.getString("task_type"));
                        t.setTaskDetails(rs.getString("task_details"));
                        t.setStatus(rs.getString("status"));
                        java.sql.Timestamp cat = rs.getTimestamp("created_at");
                        if (cat != null) t.setCreatedAt(cat.toLocalDateTime());
                        try { t.setRequestCode(rs.getString("request_code")); }   catch (Exception ign) {}
    try { t.setSrTitle(rs.getString("sr_title")); }            catch (Exception ign) {}
    try { t.setSrPriority(rs.getString("sr_priority")); }      catch (Exception ign) {}
    try { t.setSrStatus(rs.getString("sr_status")); }          catch (Exception ign) {}
    try { t.setContractType(rs.getString("contract_type")); }  catch (Exception ign) {}
                        try { t.setTechnicianName(rs.getString("technician_name")); } catch (Exception ign) {}
                        // Store extra joined data as task_details-override using transient fields via attributes trick
                        // We'll add helper fields to WorkTask or carry them via request attribute map
                        // For JSP we'll use a parallel map keyed by task.id
                        list.add(t);
                    }
                }
            }
            return list;
        }

        private int countTasksForTechnician(int techId, String status) throws Exception {
            StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM work_tasks WHERE technician_id = ?");
            List<Object> params = new ArrayList<>();
            params.add(techId);
            if (status != null && !status.isEmpty()) {
                sql.append(" AND status = ?");
                params.add(status);
            }
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (var rs = ps.executeQuery()) {
                    return rs.next() ? rs.getInt(1) : 0;
                }
            }
        }

        private Map<String, Integer> getTaskStats(int techId) throws Exception {
            String sql = """
                SELECT
                  COUNT(*) AS total,
                  SUM(status='Assigned')    AS assigned,
                  SUM(status='In Progress') AS in_progress,
                  SUM(status='Completed')   AS completed,
                  SUM(status='Cancelled')   AS cancelled
                FROM work_tasks WHERE technician_id = ?
                """;
            Map<String, Integer> m = new LinkedHashMap<>();
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql)) {
                ps.setInt(1, techId);
                try (var rs = ps.executeQuery()) {
                    if (rs.next()) {
                        m.put("total",       rs.getInt("total"));
                        m.put("assigned",    rs.getInt("assigned"));
                        m.put("in_progress", rs.getInt("in_progress"));
                        m.put("completed",   rs.getInt("completed"));
                        m.put("cancelled",   rs.getInt("cancelled"));
                    }
                }
            }
            return m;
        }

        private void updateTaskStatus(int taskId, String status) throws Exception {
            String sql = "UPDATE work_tasks SET status = ? WHERE id = ?";
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, taskId);
                ps.executeUpdate();
            }
        }

        private void markSRCompleted(int srId) throws Exception {
            String sql = "UPDATE service_requests SET status='COMPLETED', completed_at=NOW() WHERE id=?";
            try (var con = util.DBConnection.getConnection();
                 var ps  = con.prepareStatement(sql)) {
                ps.setInt(1, srId);
                ps.executeUpdate();
            }
        }

        // ── Utils ──────────────────────────────────────────────────────────
        private int parsePage(HttpServletRequest req) {
            try { int p = Integer.parseInt(req.getParameter("page")); return p < 1 ? 1 : p; }
            catch (Exception e) { return 1; }
        }

        private BigDecimal parseBD(String s) {
            try { return new BigDecimal(s.trim()); } catch (Exception e) { return BigDecimal.ZERO; }
        }

        private String[] safeArray(String[] arr) {
            return arr == null ? new String[0] : arr;
        }

        private void setFlashOk(HttpServletRequest req, String msg) {
            req.getSession().setAttribute("flash_success", msg);
        }

        private void setFlashErr(HttpServletRequest req, String msg) {
            req.getSession().setAttribute("flash_error", msg);
        }
    }