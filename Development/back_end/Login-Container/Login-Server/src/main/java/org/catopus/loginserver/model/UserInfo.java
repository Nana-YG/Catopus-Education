package org.catopus.loginserver.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "user_info")
public class UserInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "token", referencedColumnName = "token", nullable = false, unique = true)
    private User user;

    @Column(nullable = false, length = 50)
    private String nickname;

    @Column(nullable = false, length = 100)
    private String realName;

    @Column(nullable = false, length = 100)
    private String school;

    @Column(nullable = false, length = 50)
    private String className;

    @Column(nullable = false, unique = true)
    private String studentId;

    @Column(nullable = false, length = 10)
    private String gender;

    @Column(nullable = false)
    private Integer age;

    @Column(nullable = false, length = 255)
    private String subjects; // Could be a JSON string or comma-separated values

    @Column(nullable = false)
    private Boolean studentConsent;

    @Column(nullable = false)
    private Boolean guardianConsent;
}
