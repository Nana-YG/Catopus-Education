package org.catopus.Contentserver.Progress.Controller;

public class TaskUpdatePayload {
    private String subject;
    private int completed;

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public int getCompleted() {
        return completed;
    }

    public void setCompleted(int completed) {
        this.completed = completed;
    }
}
