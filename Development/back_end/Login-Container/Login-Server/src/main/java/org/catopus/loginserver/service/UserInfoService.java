package org.catopus.loginserver.service;

import java.util.Optional;

import org.catopus.loginserver.model.User;
import org.catopus.loginserver.model.UserInfo;
import org.catopus.loginserver.repository.UserInfoRepository;
import org.catopus.loginserver.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserInfoService {
    private final UserRepository userRepository;
    private final UserInfoRepository userInfoRepository;
    
    public UserInfoService(UserInfoRepository userInfoRepository, UserRepository userRepository) {
        this.userInfoRepository = userInfoRepository;
        this.userRepository = userRepository;
    }

    public Optional<UserInfo> getUserInfoByToken(String token) {
        return userInfoRepository.findByUser_Token(token);
    }

    public boolean isUserInfoComplete(UserInfo userInfo) {
        return userInfo.getNickname() != null && !userInfo.getNickname().isBlank() &&
               userInfo.getRealName() != null && !userInfo.getRealName().isBlank() &&
               userInfo.getSchool() != null && !userInfo.getSchool().isBlank() &&
               userInfo.getClassName() != null && !userInfo.getClassName().isBlank() &&
               userInfo.getStudentId() != null && !userInfo.getStudentId().isBlank() &&
               userInfo.getGender() != null && !userInfo.getGender().isBlank() &&
               userInfo.getAge() != null &&
               userInfo.getSubjects() != null && !userInfo.getSubjects().isBlank() &&
               userInfo.getStudentConsent() != null &&
               userInfo.getGuardianConsent() != null;
    }

     public void initializeUserInfo(String token, UserInfo userInfoRequest) {
        Optional<User> user = userRepository.findByToken(token);
        if (user.isEmpty()) {
            throw new RuntimeException("User not found for token: " + token);
        }
        // Suppose the info table has nothing about this user and the json has all info.
        // Create and save new UserInfo
        UserInfo userInfo = new UserInfo();
        userInfo.setUser(user.get());
        userInfo.setNickname(userInfoRequest.getNickname());
        userInfo.setRealName(userInfoRequest.getRealName());
        userInfo.setSchool(userInfoRequest.getSchool());
        userInfo.setClassName(userInfoRequest.getClassName());
        userInfo.setStudentId(userInfoRequest.getStudentId());
        userInfo.setGender(userInfoRequest.getGender());
        userInfo.setAge(userInfoRequest.getAge());
        userInfo.setSubjects(userInfoRequest.getSubjects());
        userInfo.setStudentConsent(userInfoRequest.getStudentConsent());
        userInfo.setGuardianConsent(userInfoRequest.getGuardianConsent());

        userInfoRepository.save(userInfo);
    }
}
