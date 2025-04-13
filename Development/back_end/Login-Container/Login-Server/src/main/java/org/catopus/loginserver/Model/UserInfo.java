package org.catopus.loginserver.Model;

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

    @Column(length = 50)
    private String nickname;

    @Column(length = 100)
    private String realName;

    @Column(length = 100)
    private String school;

    @Column(length = 50)
    private String className;

    @Column
    private String studentId;

    @Column(length = 10)
    private String gender;

    @Column
    private Integer age;

    @Column(length = 255)
    private String subjects;

    @Column
    private Boolean studentConsent;

    @Column
    private Boolean guardianConsent;

    @Column
    private String mobile;
}
