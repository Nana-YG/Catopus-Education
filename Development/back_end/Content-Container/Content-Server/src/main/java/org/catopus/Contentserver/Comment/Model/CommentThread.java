package org.catopus.Contentserver.Comment.Model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Document(collection = "comments")
public class CommentThread {

    @Id
    private String id;  // 格式为 "classId-taskId"
    private List<Comment> comments = new ArrayList<>();

    public CommentThread() {
    }

    public CommentThread(String id) {
        this.id = id;
    }

    // Getter & Setter
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<Comment> getComments() {
        return comments;
    }

    public void setComments(List<Comment> comments) {
        this.comments = comments;
    }
}
