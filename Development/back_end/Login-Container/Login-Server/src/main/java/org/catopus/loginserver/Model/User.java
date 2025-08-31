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

@Data
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(unique = true, nullable = false, length = 32)
    private String token;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private AccountType accountType;

    @Column(nullable = false, length = 300)
    private byte[] profilePicture;
    
    @Column(name = "magic_word", nullable = false, length = 100)
    private String magicWord;

    public User() {
        this.profilePicture = new byte[300];
        for (int i = 0; i < 300; i++) {
            this.profilePicture[i] = (byte) 255;
        }
    }

}
