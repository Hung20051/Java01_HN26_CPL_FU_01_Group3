package model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class CustomerEquipment {
    private int id;
    private int customerId;
    // Nếu mua trong hệ thống
    private Integer equipmentUnitId;
    private String serialNumber;      // từ equipment_units
    private String equipmentModel;    // từ equipment_types
    private String categoryName;
    private String unitStatus;        // status trong kho
    // Nếu mua ngoài
    private String customName;
    private String customSerial;
    private String source;            // INTERNAL / EXTERNAL
    // Chung
    private LocalDate purchasedDate;
    private LocalDate warrantyExpires;
    private String notes;
    private LocalDateTime createdAt;

    public CustomerEquipment() {}

    // Helper: tên hiển thị
    public String getDisplayName() {
        if ("EXTERNAL".equals(source)) return customName != null ? customName : "Thiết bị bên ngoài";
        return equipmentModel != null ? equipmentModel : "Thiết bị #" + id;
    }

    public String getDisplaySerial() {
        if ("EXTERNAL".equals(source)) return customSerial != null ? customSerial : "N/A";
        return serialNumber != null ? serialNumber : "N/A";
    }

    public boolean isUnderWarranty() {
        if (warrantyExpires == null) return false;
        return LocalDate.now().isBefore(warrantyExpires) || LocalDate.now().isEqual(warrantyExpires);
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public Integer getEquipmentUnitId() { return equipmentUnitId; }
    public void setEquipmentUnitId(Integer equipmentUnitId) { this.equipmentUnitId = equipmentUnitId; }

    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public String getEquipmentModel() { return equipmentModel; }
    public void setEquipmentModel(String equipmentModel) { this.equipmentModel = equipmentModel; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getUnitStatus() { return unitStatus; }
    public void setUnitStatus(String unitStatus) { this.unitStatus = unitStatus; }

    public String getCustomName() { return customName; }
    public void setCustomName(String customName) { this.customName = customName; }

    public String getCustomSerial() { return customSerial; }
    public void setCustomSerial(String customSerial) { this.customSerial = customSerial; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public LocalDate getPurchasedDate() { return purchasedDate; }
    public void setPurchasedDate(LocalDate purchasedDate) { this.purchasedDate = purchasedDate; }

    public LocalDate getWarrantyExpires() { return warrantyExpires; }
    public void setWarrantyExpires(LocalDate warrantyExpires) { this.warrantyExpires = warrantyExpires; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}