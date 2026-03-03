package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Payment {
    private int id;
    private String paymentCode;
    private int invoiceId;
    private String invoiceCode;
    private int customerId;
    private String customerName;
    private BigDecimal amount;
    private String paymentMethod;   // CASH | VNPAY
    private String status;          // PENDING | SUCCESS | FAILED | CANCELLED
    private String transactionRef;
    private String note;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public String getStatusLabel() {
        if ("PENDING".equals(status))   return "Đang xử lý";
        if ("SUCCESS".equals(status))   return "Thành công";
        if ("FAILED".equals(status))    return "Thất bại";
        if ("CANCELLED".equals(status)) return "Đã hủy";
        return status;
    }

    public String getMethodLabel() {
        if ("CASH".equals(paymentMethod))  return "Tiền mặt";
        if ("VNPAY".equals(paymentMethod)) return "VNPay";
        return paymentMethod;
    }

    // ── Getters & Setters ──
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPaymentCode() { return paymentCode; }
    public void setPaymentCode(String paymentCode) { this.paymentCode = paymentCode; }

    public int getInvoiceId() { return invoiceId; }
    public void setInvoiceId(int invoiceId) { this.invoiceId = invoiceId; }

    public String getInvoiceCode() { return invoiceCode; }
    public void setInvoiceCode(String invoiceCode) { this.invoiceCode = invoiceCode; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}