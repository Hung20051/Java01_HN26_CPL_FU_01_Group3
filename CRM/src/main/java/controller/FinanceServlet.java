package controller;

import dao.FinanceDAO;
import dao.FinanceDAO.FinanceRow;
import dao.FinanceDAO.MonthlyRevenue;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.*;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

/**
 * URL: /admin/finance
 *
 * GET  → hiển thị trang tài chính
 * GET  ?export=excel → xuất file .xlsx
 */
public class FinanceServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private final FinanceDAO dao = new FinanceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Kiểm tra quyền ADMIN ──────────────────────────────────────────
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"ADMIN".equals(user.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }

        // ── Tham số lọc ───────────────────────────────────────────────────
        String type     = nvl(req.getParameter("type"));
        String fromDate = nvl(req.getParameter("fromDate"));
        String toDate   = nvl(req.getParameter("toDate"));
        String keyword  = nvl(req.getParameter("keyword"));
        String export   = nvl(req.getParameter("export"));

        try {
            // ── Export Excel ─────────────────────────────────────────────
            if ("excel".equals(export)) {
                exportExcel(req, resp, type, fromDate, toDate, keyword);
                return;
            }

            // ── Phân trang ───────────────────────────────────────────────
            int page = 1;
            try { page = Math.max(1, Integer.parseInt(req.getParameter("page"))); }
            catch (Exception ignored) {}

            int total     = dao.countRows(type, fromDate, toDate, keyword);
            int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

            List<FinanceRow> rows = dao.getRows(type, fromDate, toDate, keyword, page, PAGE_SIZE);

            // ── Tổng quan ────────────────────────────────────────────────
            BigDecimal totalSale   = dao.getTotalSaleRevenue();
            BigDecimal totalRepair = dao.getTotalRepairRevenue();
            BigDecimal totalAll    = totalSale.add(totalRepair);
            BigDecimal unpaidAmt   = dao.getTotalUnpaidAmount();
            int        unpaidCount = dao.countUnpaidInvoices();

            // ── Dữ liệu chart (12 tháng) ─────────────────────────────────
            List<MonthlyRevenue> monthly = dao.getMonthlyRevenue(12);

            // ── Set attributes ───────────────────────────────────────────
            req.setAttribute("rows",        rows);
            req.setAttribute("totalSale",   totalSale);
            req.setAttribute("totalRepair", totalRepair);
            req.setAttribute("totalAll",    totalAll);
            req.setAttribute("unpaidAmt",   unpaidAmt);
            req.setAttribute("unpaidCount", unpaidCount);
            req.setAttribute("monthly",     monthly);
            req.setAttribute("total",       total);
            req.setAttribute("page",        page);
            req.setAttribute("totalPages",  totalPages);
            req.setAttribute("type",        type);
            req.setAttribute("fromDate",    fromDate);
            req.setAttribute("toDate",      toDate);
            req.setAttribute("keyword",     keyword);

            req.getRequestDispatcher("/admin-finance.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi tải dữ liệu tài chính: " + e.getMessage());
        }
    }

    // ── Export Excel ──────────────────────────────────────────────────────────

    private void exportExcel(HttpServletRequest req, HttpServletResponse resp,
                              String type, String fromDate, String toDate, String keyword)
            throws Exception {

        List<FinanceRow> rows = dao.getAllRows(type, fromDate, toDate, keyword);

        // Tên file: Finance_2026-03-31.xlsx
        String fileName = "Finance_"
                + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm"))
                + ".xlsx";

        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (Workbook wb = new XSSFWorkbook();
             OutputStream out = resp.getOutputStream()) {

            // ── Sheet 1: Chi tiết giao dịch ───────────────────────────────
            Sheet sheet = wb.createSheet("Transaction Details");
            sheet.setColumnWidth(0,  12 * 256);
            sheet.setColumnWidth(1,  16 * 256);
            sheet.setColumnWidth(2,  16 * 256);
            sheet.setColumnWidth(3,  26 * 256);
            sheet.setColumnWidth(4,  14 * 256);
            sheet.setColumnWidth(5,  14 * 256);
            sheet.setColumnWidth(6,  18 * 256);
            sheet.setColumnWidth(7,  12 * 256);
            sheet.setColumnWidth(8,  20 * 256);

            // Style header
            CellStyle headerStyle = wb.createCellStyle();
            Font hFont = wb.createFont();
            hFont.setBold(true);
            hFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(hFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            Font hFontW = wb.createFont();
            hFontW.setBold(true);
            hFontW.setColor(IndexedColors.WHITE.getIndex());
            hFontW.setFontHeightInPoints((short) 11);
            headerStyle.setFont(hFontW);
            headerStyle.setBorderBottom(BorderStyle.THIN);

            // Style tiền
            CellStyle moneyStyle = wb.createCellStyle();
            DataFormat fmt = wb.createDataFormat();
            moneyStyle.setDataFormat(fmt.getFormat("#,##0"));

            // Style loại PURCHASE
            CellStyle saleStyle = wb.createCellStyle();
            saleStyle.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
            saleStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // Style loại REPAIR
            CellStyle repairStyle = wb.createCellStyle();
            repairStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
            repairStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // Header row
            Row header = sheet.createRow(0);
            String[] cols = {"#","Payment Code","Invoice Code","Customer",
                             "Type","Method","Amount (VND)","Status","Date"};
            for (int i = 0; i < cols.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(cols[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            int rowNum = 1;
            BigDecimal sumSale   = BigDecimal.ZERO;
            BigDecimal sumRepair = BigDecimal.ZERO;

            for (FinanceRow r : rows) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(rowNum - 1);
                row.createCell(1).setCellValue(r.paymentCode);
                row.createCell(2).setCellValue(r.invoiceCode);
                row.createCell(3).setCellValue(r.customerName);

                Cell typeCell = row.createCell(4);
                typeCell.setCellValue("PURCHASE".equals(r.invoiceType) ? "Sales" : "Repair");

                row.createCell(5).setCellValue("CASH".equals(r.paymentMethod) ? "Cash" : "VNPay");

                Cell amtCell = row.createCell(6);
                if (r.amount != null) {
                    amtCell.setCellValue(r.amount.doubleValue());
                    amtCell.setCellStyle(moneyStyle);
                }
                row.createCell(7).setCellValue(translateStatus(r.status));
                row.createCell(8).setCellValue(
                        r.createdAt != null ? r.createdAt.toLocalDateTime().format(dtf) : "");

                // Cộng tổng
                if ("SUCCESS".equals(r.status) && r.amount != null) {
                    if ("PURCHASE".equals(r.invoiceType)) sumSale   = sumSale.add(r.amount);
                    else                                   sumRepair = sumRepair.add(r.amount);
                }
            }

            // Dòng tổng kết
            Row sumRow = sheet.createRow(rowNum + 1);
            CellStyle totalStyle = wb.createCellStyle();
            Font tf = wb.createFont(); tf.setBold(true);
            totalStyle.setFont(tf);
            totalStyle.setFillForegroundColor(IndexedColors.LEMON_CHIFFON.getIndex());
            totalStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            Cell lbl1 = sumRow.createCell(5); lbl1.setCellValue("Total Sales:"); lbl1.setCellStyle(totalStyle);
            Cell val1 = sumRow.createCell(6); val1.setCellValue(sumSale.doubleValue()); val1.setCellStyle(moneyStyle);

            Row sumRow2 = sheet.createRow(rowNum + 2);
            Cell lbl2 = sumRow2.createCell(5); lbl2.setCellValue("Total Repair:"); lbl2.setCellStyle(totalStyle);
            Cell val2 = sumRow2.createCell(6); val2.setCellValue(sumRepair.doubleValue()); val2.setCellStyle(moneyStyle);

            Row sumRow3 = sheet.createRow(rowNum + 3);
            Cell lbl3 = sumRow3.createCell(5); lbl3.setCellValue("Grand Total:"); lbl3.setCellStyle(totalStyle);
            Cell val3 = sumRow3.createCell(6);
            val3.setCellValue(sumSale.add(sumRepair).doubleValue()); val3.setCellStyle(moneyStyle);

            // ── Sheet 2: Tổng hợp theo tháng ─────────────────────────────
            Sheet sheet2 = wb.createSheet("Monthly Revenue");
            sheet2.setColumnWidth(0, 14 * 256);
            sheet2.setColumnWidth(1, 20 * 256);
            sheet2.setColumnWidth(2, 20 * 256);
            sheet2.setColumnWidth(3, 20 * 256);

            Row h2 = sheet2.createRow(0);
            String[] cols2 = {"Month","Sales Revenue","Repair Revenue","Total"};
            for (int i = 0; i < cols2.length; i++) {
                Cell c2 = h2.createCell(i); c2.setCellValue(cols2[i]); c2.setCellStyle(headerStyle);
            }

            List<MonthlyRevenue> monthly = dao.getMonthlyRevenue(12);
            int r2 = 1;
            for (MonthlyRevenue mr : monthly) {
                Row row2 = sheet2.createRow(r2++);
                row2.createCell(0).setCellValue(mr.month);
                Cell s = row2.createCell(1); s.setCellValue(mr.sale.doubleValue());   s.setCellStyle(moneyStyle);
                Cell p = row2.createCell(2); p.setCellValue(mr.repair.doubleValue()); p.setCellStyle(moneyStyle);
                Cell t = row2.createCell(3);
                t.setCellValue(mr.sale.add(mr.repair).doubleValue()); t.setCellStyle(moneyStyle);
            }

            wb.write(out);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private String nvl(String s) { return s != null ? s.trim() : ""; }

    private String translateStatus(String s) {
        if (s == null) return "";
        return switch (s) {
            case "SUCCESS"   -> "Successful";
            case "PENDING"   -> "Processing";
            case "FAILED"    -> "Failed";
            case "CANCELLED" -> "Cancelled";
            default          -> s;
        };
    }
}