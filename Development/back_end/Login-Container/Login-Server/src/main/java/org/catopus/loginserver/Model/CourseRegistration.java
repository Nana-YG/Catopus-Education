package org.catopus.loginserver.Model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "classes")
public class CourseRegistration {

    @Id
    @Column(nullable = false, unique = true, length = 8)
    private String classId = "";

    @Column(nullable = false)
    private String className = "";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CoursePackage coursePackage = CoursePackage.BASIC; 

    @Column(nullable = false)
    private String joinKey = "";

    @Column(nullable = false)
    private String teacher = "";

    @Column(length = 2000)
    private String students = "";

    @Column(nullable = false)
    private boolean current = true;
}
