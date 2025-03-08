package org.catopus.loginserver.repository;

import java.util.Optional;

import org.catopus.loginserver.model.UserInfo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserInfoRepository extends JpaRepository<UserInfo, Long> {
    Optional<UserInfo> findByUser_Token(String token);
}
