package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class Contract {

    private int id;
    private String contractCode;
    private int customerId;
    private String customerName;
    private int createdBy;
    private String createdByName;
    private String contractType;  // WARRANTY / MAINTENANCE
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;        // ACTIVE / EXPIRED / CANCELLED
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Extra
    private int equipmentCount;
    private int serviceRequestCount;
    private List<CustomerEquipment> equipmentList;

    public Contract() {
    }

    public String getContractTypeLabel() {
        return "WARRANTY".equals(contractType) ? "Bảo hành" : "Bảo trì";
    }

    public String getStatusLabel() {
        switch (status == null ? "" : status) {
            case "ACTIVE":
                return "Đang hoạt động";
            case "EXPIRED":
                return "Đã hết hạn";
            case "CANCELLED":
                return "Đã hủy";
            default:
                return status;
        }
    }

    public boolean isActive() {
        return "ACTIVE".equals(status);
    }

    // Getters & Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getContractCode() {
        return contractCode;
    }

    public void setContractCode(String contractCode) {
        this.contractCode = contractCode;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getEquipmentCount() {
        return equipmentCount;
    }

    public void setEquipmentCount(int equipmentCount) {
        this.equipmentCount = equipmentCount;
    }

    public int getServiceRequestCount() {
        return serviceRequestCount;
    }

    public void setServiceRequestCount(int serviceRequestCount) {
        this.serviceRequestCount = serviceRequestCount;
    }

    public List<CustomerEquipment> getEquipmentList() {
        return equipmentList;
    }

    public void setEquipmentList(List<CustomerEquipment> equipmentList) {
        this.equipmentList = equipmentList;
    }
}
