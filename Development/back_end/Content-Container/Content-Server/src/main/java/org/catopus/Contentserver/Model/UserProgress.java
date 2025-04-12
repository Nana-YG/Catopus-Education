package org.catopus.Contentserver.Model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Map;

@Document(collection = "progress")
public class UserProgress {

    @Id
    private String username;

    private Map<String, ClassProgress> classes;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Map<String, ClassProgress> getClasses() {
        return classes;
    }

    public void setClasses(Map<String, ClassProgress> classes) {
        this.classes = classes;
    }
}
