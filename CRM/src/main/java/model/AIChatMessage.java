package model;
 
import java.time.LocalDateTime;
 
public class AIChatMessage {
    private int           id;
    private int           userId;
    private String        role;      // "user" | "assistant"
    private String        content;
    private LocalDateTime createdAt;
 
    public AIChatMessage() {}
 
    public AIChatMessage(int userId, String role, String content) {
        this.userId  = userId;
        this.role    = role;
        this.content = content;
    }
 
    public int           getId()        { return id; }
    public void          setId(int v)   { id = v; }
 
    public int           getUserId()       { return userId; }
    public void          setUserId(int v)  { userId = v; }
 
    public String        getRole()         { return role; }
    public void          setRole(String v) { role = v; }
 
    public String        getContent()         { return content; }
    public void          setContent(String v) { content = v; }
 
    public LocalDateTime getCreatedAt()         { return createdAt; }
    public void          setCreatedAt(LocalDateTime v) { createdAt = v; }
}
 