package org.catopus.loginserver.controller;

import org.catopus.loginserver.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/login")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
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

    @PostMapping("/log-in")
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
}
