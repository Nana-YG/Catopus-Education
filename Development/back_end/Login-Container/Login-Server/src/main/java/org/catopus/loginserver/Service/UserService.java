package org.catopus.loginserver.Service;

import java.security.SecureRandom;
import java.util.Optional;

import org.catopus.loginserver.Model.AccountType;
import org.catopus.loginserver.Model.User;
import org.catopus.loginserver.Repository.UserRepository;
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

    public boolean register(String username, String password, AccountType accountType, String magicWord) {
        if (userRepository.findByUsername(username).isPresent()) {
            return false; // user already exists
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password)); // encrypt password
        user.setToken(generateToken()); // generate random token
        user.setAccountType(accountType);
        user.setMagicWord(magicWord);
        userRepository.save(user);
        return true;
    }

    public boolean resetPasswordByMagicword(String username, String magicword, String newPassword) {
        Optional<User> uOpt = userRepository.findByUsername(username);
        if (uOpt.isEmpty()) {
            return false;
        }
        User u = uOpt.get();
        if (!magicword.equals(u.getMagicWord())) {
            return false;
        }

        u.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(u);
        return true;
    }

    public String login(String username, String password) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return null; // user does not exist
        }
        User user = userOpt.get();
        if (passwordEncoder.matches(password, user.getPassword())) {
            return user.getToken(); // return token
        }
        return null; // password is incorrect
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

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public void saveUser(User user) {
        userRepository.save(user);
    }
}
