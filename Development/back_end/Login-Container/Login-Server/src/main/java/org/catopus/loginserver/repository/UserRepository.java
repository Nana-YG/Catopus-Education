package org.catopus.loginserver.repository;

import java.util.Optional;

import org.catopus.loginserver.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByUsernameAndToken(String username, String token);
    Optional<User> findByToken(String token);
}
