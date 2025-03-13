package org.catopus.loginserver.service;

import java.security.SecureRandom;
import java.util.Optional;

import org.catopus.loginserver.model.AccountType;
import org.catopus.loginserver.model.User;
import org.catopus.loginserver.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    private String generateToken() {
        SecureRandom random = new SecureRandom();
        StringBuilder token = new StringBuilder(32);
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for (int i = 0; i < 32; i++) {
            token.append(characters.charAt(random.nextInt(characters.length())));
        }
        return token.toString();
    }

    public String getTokenByUsername(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        return userOpt.map(User::getToken).orElse(null);
    }

    public boolean register(String username, String password, AccountType accountType) {
        if (userRepository.findByUsername(username).isPresent()) {
            return false; // 用户已存在
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password)); // 加密密码
        user.setToken(generateToken()); // 生成随机 token
        user.setAccountType(accountType);
        userRepository.save(user);
        return true;
    }

    public String login(String username, String password) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return null; // 用户不存在
        }
        User user = userOpt.get();
        if (passwordEncoder.matches(password, user.getPassword())) {
            return user.getToken(); // 返回 token
        }
        return null; // 密码错误
    }

    public boolean isTokenValidForUser(String username, String token) {
        Optional<User> user = userRepository.findByUsernameAndToken(username, token);
        return user.isPresent();
    }

    public AccountType getAccountTypeByUsername(String username) {
        return userRepository.findByUsername(username)
                .map(user -> {
                    if (user.getAccountType() == null) {
                        throw new IllegalStateException("Account type is missing for this user.");
                    }
                    return user.getAccountType();
                })
                .orElseThrow(() -> new IllegalStateException("User not found"));
    }

}
