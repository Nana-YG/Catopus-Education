package org.catopus.loginserver.Service;

import java.lang.reflect.Field;
import java.util.Optional;

import org.catopus.loginserver.Model.User;
import org.catopus.loginserver.Model.UserInfo;
import org.catopus.loginserver.Repository.UserInfoRepository;
import org.catopus.loginserver.Repository.UserRepository;
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
        Field[] fields = UserInfo.class.getDeclaredFields();

        for (Field field : fields) {
            field.setAccessible(true);

            // Skip `id` and `user` (the token link)
            if (field.getName().equals("id") || field.getName().equals("user")) {
                continue;
            }

            try {
                Object value = field.get(userInfo);
                if (value == null) {
                    return false;
                }

                if (value instanceof String && ((String) value).isBlank()) {
                    return false;
                }
            } catch (IllegalAccessException e) {
                throw new RuntimeException("Error accessing field: " + field.getName(), e);
            }
        }

        return true;
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
        userInfo.setMobile(userInfoRequest.getMobile());
        
        userInfoRepository.save(userInfo);
    }
}
