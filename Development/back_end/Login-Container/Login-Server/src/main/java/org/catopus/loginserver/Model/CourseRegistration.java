package org.catopus.loginserver.Model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "classes")
public class CourseRegistration {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String className;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CoursePackage coursePackage;

    @Column(nullable = false)
    private String joinKey;

    @Column(nullable = false)
    private String teacher;

    @Column(length = 2000)
    private String students = "";

    @Column(nullable = false)
    private boolean current = true;
}
