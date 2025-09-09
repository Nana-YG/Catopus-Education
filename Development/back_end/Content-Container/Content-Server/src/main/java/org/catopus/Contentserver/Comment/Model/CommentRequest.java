package org.catopus.Contentserver.Comment.Model;

public class CommentRequest {
    private String username;
    private String attitude;
    private String content;
    private String timestamp;
    private String replyTo; // 可以是 "system" 或者某个 commentId

    // Getters & Setters ...
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getAttitude() {
        return attitude;
    }

    public void setAttitude(String attitude) {
        this.attitude = attitude;
    }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getReplyTo() {
        return replyTo;
    }

    public void setReplyTo(String replyTo) {
        this.replyTo = replyTo;
    }
}
