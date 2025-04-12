package org.catopus.loginserver.Repository;

import java.util.Optional;

import org.catopus.loginserver.Model.UserInfo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserInfoRepository extends JpaRepository<UserInfo, Long> {
    Optional<UserInfo> findByUser_Token(String token);
}
