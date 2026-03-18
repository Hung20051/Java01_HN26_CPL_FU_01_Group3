package model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ChatMessage {

    private int id;
    private int senderId;
    private String senderName;
    private String senderAvatar;
    private int receiverId;
    private String message;
    private boolean read;
    private boolean delivered;
    private LocalDateTime createdAt;
    private boolean recalled;
    private boolean pinned;

    // Attachment fields
    private String attachmentUrl;
    private String attachmentName;
    private String attachmentType; // IMAGE / FILE

    public String getTimeFormatted() {
        if (createdAt == null) {
            return "";
        }
        if (createdAt.toLocalDate().equals(LocalDate.now())) {
            return createdAt.format(DateTimeFormatter.ofPattern("HH:mm"));
        }
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM HH:mm"));
    }

    public boolean hasAttachment() {
        return attachmentUrl != null && !attachmentUrl.isEmpty();
    }

    public boolean isImage() {
        return "IMAGE".equals(attachmentType);
    }

    // ── Getters & Setters ──
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int v) {
        senderId = v;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String v) {
        senderName = v;
    }

    public String getSenderAvatar() {
        return senderAvatar;
    }

    public void setSenderAvatar(String v) {
        senderAvatar = v;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int v) {
        receiverId = v;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String v) {
        message = v;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean v) {
        read = v;
    }

    public boolean isDelivered() {
        return delivered;
    }

    public void setDelivered(boolean v) {
        delivered = v;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime v) {
        createdAt = v;
    }

    public boolean isRecalled() {
        return recalled;
    }

    public void setRecalled(boolean v) {
        recalled = v;
    }

    public boolean isPinned() {
        return pinned;
    }

    public void setPinned(boolean v) {
        pinned = v;
    }

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public void setAttachmentUrl(String v) {
        attachmentUrl = v;
    }

    public String getAttachmentName() {
        return attachmentName;
    }

    public void setAttachmentName(String v) {
        attachmentName = v;
    }

    public String getAttachmentType() {
        return attachmentType;
    }

    public void setAttachmentType(String v) {
        attachmentType = v;
    }
}
