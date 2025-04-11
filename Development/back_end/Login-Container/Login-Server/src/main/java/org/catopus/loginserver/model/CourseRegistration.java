package org.catopus.loginserver.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data; 

@Data
@Entity
@Table(name = "courses") 
public class CourseRegistration {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String courseName;
    
    @Column(unique = true, nullable = false)
    private String courseCode;

    @Column(nullable = false)
    private String teacher;

    @Column(nullable = false)
    private String students;

    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean current = true;
}
