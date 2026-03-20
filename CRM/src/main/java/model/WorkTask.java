package model;

import java.time.LocalDateTime;

public class WorkTask {
    private int id;
    private Integer requestId;
    private int technicianId;
    private String taskType;
    private String taskDetails;
    private String status;
    private LocalDateTime createdAt;
    private String technicianName; // joined

    public WorkTask() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }
    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }
    public String getTaskType() { return taskType; }
    public void setTaskType(String taskType) { this.taskType = taskType; }
    public String getTaskDetails() { return taskDetails; }
    public void setTaskDetails(String taskDetails) { this.taskDetails = taskDetails; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }
}