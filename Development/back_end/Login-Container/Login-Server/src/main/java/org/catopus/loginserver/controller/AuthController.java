package org.catopus.loginserver.controller;

import java.util.Map;
import java.util.Optional;

import org.catopus.loginserver.model.UserInfo;
import org.catopus.loginserver.service.UserInfoService;
import org.catopus.loginserver.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/login")
public class AuthController {

    private final UserService userService;
    private final UserInfoService userInfoService;

    public AuthController(UserService userService, UserInfoService userInfoService) {
        this.userService = userService;
        this.userInfoService = userInfoService;
    }


    @PostMapping("/signup")
    public ResponseEntity<?> register(
            @RequestHeader(value = "Username", required = false) String username,
            @RequestHeader(value = "Password", required = false) String password) {

        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username and password required"));
        }

        boolean success = userService.register(username, password);
        if (success) {
            String token = userService.getTokenByUsername(username); // 注册成功返回 token
            return ResponseEntity.ok(Map.of("message", "User registered successfully", "token", token));
        } else {
            return ResponseEntity.badRequest().body(Map.of("error", "User already exists"));
        }
    }

    @PostMapping("/signin")
    public ResponseEntity<?> login(
            @RequestHeader(value = "Username", required = false) String username,
            @RequestHeader(value = "Password", required = false) String password) {

        if (username == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username and password required"));
        }

        String token = userService.login(username, password);
        if (token != null) {
            return ResponseEntity.ok(Map.of("message", "Login successful", "token", token));
        } else {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid username or password"));
        }
    }

    @GetMapping("/check")
    public ResponseEntity<?> checkLogin(
            @RequestHeader(value = "Username", required = false) String username,
            @RequestHeader(value = "Token", required = false) String token) {

        if (username == null || token == null || username.isBlank() || token.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username and Token required"));
        }

        boolean isValid = userService.isTokenValidForUser(username, token);
        if (!isValid) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized: Invalid token or username"));
        }

        Optional<UserInfo> userInfo = userInfoService.getUserInfoByToken(token);
        if (userInfo.isEmpty() || !userInfoService.isUserInfoComplete(userInfo.get())) {
            return ResponseEntity.status(204).build(); // No Content
        }

        return ResponseEntity.ok(userInfo.get());
    }

    @PostMapping("/signup/setinfo")
    public ResponseEntity<?> setUserInfo(
            @RequestHeader(value = "Username", required = true) String username,
            @RequestHeader(value = "Token", required = true) String token,
            @RequestBody UserInfo userInfoRequest) {

        // Checking validation on token & username
        boolean isValid = userService.isTokenValidForUser(username, token);
        if (!isValid) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized: Invalid token or username"));
        }
        
        // Initializing the current user's info in info table.
        userInfoService.initializeUserInfo(token, userInfoRequest);

        return ResponseEntity.ok(Map.of("message", "User info initialized successfully"));
    }
}
