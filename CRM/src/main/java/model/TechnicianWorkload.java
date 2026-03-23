package model;

import java.time.LocalDateTime;

public class TechnicianWorkload {
    private int id;
    private int technicianId;
    private int currentActiveTasks;
    private int maxConcurrentTasks;
    private LocalDateTime lastAssignedDate;
    private LocalDateTime lastUpdated;
    private String technicianName;   // joined
    private String technicianEmail;  // joined
    private String avatarUrl;        // joined from users.avatar_url

    public TechnicianWorkload() {}

    public boolean isAvailable() {
        return currentActiveTasks < maxConcurrentTasks;
    }

    public int getAvailableSlots() {
        return maxConcurrentTasks - currentActiveTasks;
    }

    public int getLoadPercent() {
        if (maxConcurrentTasks == 0) return 100;
        return Math.min(100, (int)((double) currentActiveTasks / maxConcurrentTasks * 100));
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTechnicianId() { return technicianId; }
    public void setTechnicianId(int technicianId) { this.technicianId = technicianId; }
    public int getCurrentActiveTasks() { return currentActiveTasks; }
    public void setCurrentActiveTasks(int currentActiveTasks) { this.currentActiveTasks = currentActiveTasks; }
    public int getMaxConcurrentTasks() { return maxConcurrentTasks; }
    public void setMaxConcurrentTasks(int maxConcurrentTasks) { this.maxConcurrentTasks = maxConcurrentTasks; }
    public LocalDateTime getLastAssignedDate() { return lastAssignedDate; }
    public void setLastAssignedDate(LocalDateTime lastAssignedDate) { this.lastAssignedDate = lastAssignedDate; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }
    public String getTechnicianName() { return technicianName; }
    public void setTechnicianName(String technicianName) { this.technicianName = technicianName; }
    public String getTechnicianEmail() { return technicianEmail; }
    public void setTechnicianEmail(String technicianEmail) { this.technicianEmail = technicianEmail; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
}