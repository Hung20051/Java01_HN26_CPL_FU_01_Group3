package model;

import java.time.LocalDateTime;

public class PartUnit {

    private int id;
    private int partTypeId;
    private String partTypeName;
    private String status; // AVAILABLE, INUSE, FAULTY, RETIRED
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public PartUnit() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPartTypeId() {
        return partTypeId;
    }

    public void setPartTypeId(int partTypeId) {
        this.partTypeId = partTypeId;
    }

    public String getPartTypeName() {
        return partTypeName;
    }

    public void setPartTypeName(String partTypeName) {
        this.partTypeName = partTypeName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
}
