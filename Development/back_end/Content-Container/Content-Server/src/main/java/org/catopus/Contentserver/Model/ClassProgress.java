package org.catopus.Contentserver.Model;

import java.util.Map;

public class ClassProgress {

    private String subject;  // e.g., "math201"
    private Map<String, Integer> tasks;  // taskId -> 0 or 1

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public Map<String, Integer> getTasks() {
        return tasks;
    }

    public void setTasks(Map<String, Integer> tasks) {
        this.tasks = tasks;
    }
}
