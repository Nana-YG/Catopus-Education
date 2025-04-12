package org.catopus.Contentserver.Comment.Model;

public class CommentRequest {
    private String username;
    private String timestamp;
    private String content;

    // Getters and Setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}
