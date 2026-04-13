package model;

import java.time.LocalDateTime;

public class EquipmentType {

    private int id;
    private String model;
    private int categoryId;
    private String categoryName;
    private String description;
    private double unitPrice;
    private String imageUrl;
    private int updatedBy;
    private String updatedByUsername;
    private LocalDateTime updatedAt;
    private LocalDateTime createdAt;
    // Stats
    private int totalUnits;
    private int availableUnits;
    private int inuseUnits;
    private int faultyUnits;
    private int retiredUnits;

    public EquipmentType() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(int updatedBy) {
        this.updatedBy = updatedBy;
    }

    public String getUpdatedByUsername() {
        return updatedByUsername;
    }

    public void setUpdatedByUsername(String u) {
        this.updatedByUsername = u;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public int getTotalUnits() {
        return totalUnits;
    }

    public void setTotalUnits(int totalUnits) {
        this.totalUnits = totalUnits;
    }

    public int getAvailableUnits() {
        return availableUnits;
    }

    public void setAvailableUnits(int availableUnits) {
        this.availableUnits = availableUnits;
    }

    public int getInuseUnits() {
        return inuseUnits;
    }

    public void setInuseUnits(int inuseUnits) {
        this.inuseUnits = inuseUnits;
    }

    public int getFaultyUnits() {
        return faultyUnits;
    }

    public void setFaultyUnits(int faultyUnits) {
        this.faultyUnits = faultyUnits;
    }

    public int getRetiredUnits() {
        return retiredUnits;
    }

    public void setRetiredUnits(int retiredUnits) {
        this.retiredUnits = retiredUnits;
    }
}
