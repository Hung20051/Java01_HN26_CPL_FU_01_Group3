package controller;

import dao.InvoiceDAO;
import dao.PaymentDAO;
import model.Invoice;
import model.Payment;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class PaymentServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String ctx = req.getContextPath();
        String action = req.getParameter("action");
        String invIdStr = req.getParameter("invoiceId");

        try {
            int invoiceId = Integer.parseInt(invIdStr);
            Invoice inv = invoiceDAO.getById(invoiceId);

            // Bảo vệ: hóa đơn phải thuộc customer này và còn UNPAID
            if (inv == null || inv.getCustomerId() != me.getId() || !"UNPAID".equals(inv.getStatus())) {
                resp.sendRedirect(ctx + "/customerInvoices?error=invalid");
                return;
            }

            // ── THANH TOÁN TIỀN MẶT ──────────────────────────────────────────
            if ("cash".equals(action)) {
                // Tạo payment SUCCESS ngay (tiền mặt xác nhận tại chỗ)
                // createPayment cũng tự update invoice -> PAID trong cùng 1 transaction
                Payment pay = paymentDAO.createPayment(
                        invoiceId,
                        me.getId(),
                        inv.getTotalAmount(),
                        "CASH",
                        "SUCCESS",
                        null,
                        "Khách hàng thanh toán tiền mặt trực tiếp"
                );
                resp.sendRedirect(ctx + "/customerInvoices?action=detail&id=" + invoiceId
                        + "&paySuccess=cash&payCode=" + pay.getPaymentCode());

                // ── KHỞI TẠO VNPAY ───────────────────────────────────────────────
            } else if ("vnpay_simulate".equals(action)) {
                // Tạo bản ghi PENDING trong DB trước khi vào cổng giả lập
                Payment pay = paymentDAO.createPayment(
                        invoiceId,
                        me.getId(),
                        inv.getTotalAmount(),
                        "VNPAY",
                        "PENDING",
                        null,
                        "Khởi tạo thanh toán VNPay"
                );
                req.getSession().setAttribute("pendingPaymentId", pay.getId());
                req.getSession().setAttribute("pendingInvoiceId", invoiceId);
                req.getSession().setAttribute("pendingInvoiceCode", inv.getInvoiceCode());
                req.getSession().setAttribute("pendingAmount",
                        inv.getTotalAmount() != null ? inv.getTotalAmount().toPlainString() : "0");
                resp.sendRedirect(ctx + "/customerPayment?action=vnpay_gateway");

                // ── VNPAY CONFIRM (callback giả lập từ vnpayGateway.jsp) ─────────
            } else if ("vnpay_confirm".equals(action)) {
                Integer pendingPayId = (Integer) req.getSession().getAttribute("pendingPaymentId");
                Integer pendingInvId = (Integer) req.getSession().getAttribute("pendingInvoiceId");

                // ✅
                if (pendingPayId == null || pendingInvId == null || !pendingInvId.equals(invoiceId)) {
                    resp.sendRedirect(ctx + "/customerInvoices?error=session_expired");
                    return;
                }

                // Sinh transaction_ref giả lập
                String txRef = "VNPAY" + System.currentTimeMillis();
                // updateStatus cũng tự update invoice -> PAID trong cùng 1 transaction
                paymentDAO.updateStatus(pendingPayId, "SUCCESS", txRef);

                req.getSession().removeAttribute("pendingPaymentId");
                req.getSession().removeAttribute("pendingInvoiceId");
                req.getSession().removeAttribute("pendingInvoiceCode");
                req.getSession().removeAttribute("pendingAmount");

                resp.sendRedirect(ctx + "/customerInvoices?action=detail&id=" + invoiceId
                        + "&paySuccess=vnpay");

                // ── VNPAY HỦY ────────────────────────────────────────────────────
            } else if ("vnpay_cancel".equals(action)) {
                Integer pendingPayId = (Integer) req.getSession().getAttribute("pendingPaymentId");
                if (pendingPayId != null) {
                    paymentDAO.updateStatus(pendingPayId, "CANCELLED", null);
                    req.getSession().removeAttribute("pendingPaymentId");
                    req.getSession().removeAttribute("pendingInvoiceId");
                    req.getSession().removeAttribute("pendingInvoiceCode");
                    req.getSession().removeAttribute("pendingAmount");
                }
                resp.sendRedirect(ctx + "/customerInvoices?action=detail&id=" + invoiceId);

            } else {
                resp.sendRedirect(ctx + "/customerInvoices");
            }

        } catch (NumberFormatException e) {
            resp.sendRedirect(ctx + "/customerInvoices?error=invalid");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(ctx + "/customerInvoices?error=system");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        if (me == null || !"CUSTOMER".equals(me.getRoleName())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("vnpay_gateway".equals(action)) {
            Integer invoiceId = (Integer) req.getSession().getAttribute("pendingInvoiceId");
            String invoiceCode = (String) req.getSession().getAttribute("pendingInvoiceCode");
            String amount = (String) req.getSession().getAttribute("pendingAmount");
            if (invoiceId == null) {
                resp.sendRedirect(req.getContextPath() + "/customerInvoices");
                return;
            }
            req.setAttribute("invoiceId", invoiceId);
            req.setAttribute("invoiceCode", invoiceCode);
            req.setAttribute("amount", amount);
            req.getRequestDispatcher("/vnpayGateway.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/customerInvoices");
        }
    }
}
