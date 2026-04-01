package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class RepairReport {
    private int id;
    private int workTaskId;
    private int serviceRequestId;
    private int technicianId;
    private String reportCode;
    private String diagnosis;
    private String workDone;
    private BigDecimal laborCost;
    private String status;  // DRAFT / SUBMITTED
    private LocalDateTime submittedAt;
    private Integer invoiceId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Joined fields
    private String technicianName;
    private String technicianAvatarUrl;
    private String requestCode;
    private String requestTitle;
    private String contractType;   // WARRANTY / MAINTENANCE
    private String customerName;
    private int customerId;
    private String requestStatus;
private String invoiceStatus;
    private List<RepairReportPart> parts;

    public RepairReport() {}

    public String getStatusLabel() {
        return "SUBMITTED".equals(status) ? "Submitted" : "Draft";
    }

    // ── Getters & Setters ──
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getWorkTaskId() { return workTaskId; }
    public void setWorkTaskId(int workTaskId) { this.workTaskId = workTaskId; }

    public int getServiceRequestId() { return serviceRequestId; }
    public void setServiceRequestId(int serviceRequestId) { this.serviceRequestId = serviceRequestId; }

    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }

    public String getReportCode() { return reportCode; }
    public void setReportCode(String reportCode) { this.reportCode = reportCode; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public String getWorkDone() { return workDone; }
    public void setWorkDone(String workDone) { this.workDone = workDone; }

    public BigDecimal getLaborCost() { return laborCost; }
    public void setLaborCost(BigDecimal laborCost) { this.laborCost = laborCost; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }

    public Integer getInvoiceId() { return invoiceId; }
    public void setInvoiceId(Integer invoiceId) { this.invoiceId = invoiceId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }

    public String getTechnicianAvatarUrl() { return technicianAvatarUrl; }
    public void setTechnicianAvatarUrl(String technicianAvatarUrl) { this.technicianAvatarUrl = technicianAvatarUrl; }

    public String getRequestCode() { return requestCode; }
    public void setRequestCode(String requestCode) { this.requestCode = requestCode; }

    public String getRequestTitle() { return requestTitle; }
    public void setRequestTitle(String requestTitle) { this.requestTitle = requestTitle; }

    public String getContractType() { return contractType; }
    public void setContractType(String contractType) { this.contractType = contractType; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public String getRequestStatus() { return requestStatus; }
    public void setRequestStatus(String requestStatus) { this.requestStatus = requestStatus; }

    public List<RepairReportPart> getParts() { return parts; }
    public void setParts(List<RepairReportPart> parts) { this.parts = parts; }
    public String getInvoiceStatus() { return invoiceStatus; }
public void setInvoiceStatus(String invoiceStatus) { this.invoiceStatus = invoiceStatus; }
}