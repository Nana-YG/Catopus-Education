package org.catopus.loginserver.Controller;

import java.util.Base64;
import java.util.Map;
import java.util.Optional;

import org.catopus.loginserver.Model.AccountType;
import org.catopus.loginserver.Model.User;
import org.catopus.loginserver.Model.UserInfo;
import org.catopus.loginserver.Service.UserInfoService;
import org.catopus.loginserver.Service.UserService;
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
            @RequestHeader(value = "Password", required = false) String password,
            @RequestHeader(value = "AccountType", required = false) String accountTypeStr) {

        if (username == null || password == null || accountTypeStr == null || username.isBlank() || password.isBlank() || accountTypeStr.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username, password and account type are required"));
        }

        AccountType accountType = AccountType.valueOf(accountTypeStr.toUpperCase());

        boolean success = userService.register(username, password, accountType);
        if (success) {
            String token = userService.getTokenByUsername(username);
            return ResponseEntity.ok(Map.of(
                    "message", "Register successful",
                    "username", username,
                    "token", token,
                    "accountType", accountType.name()
            ));
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
            try {
                AccountType accountType = userService.getAccountTypeByUsername(username);
                return ResponseEntity.ok(Map.of(
                        "message", "Login successful",
                        "username", username,
                        "token", token,
                        "accountType", accountType.name()
                ));
            } catch (IllegalStateException e) {
                return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
            }
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
        AccountType accountType = userService.getAccountTypeByUsername(username);

        if (accountType == AccountType.TEACHER) {
            return ResponseEntity.ok(Map.of("message", "Notice, now teachers do not need to fill the personal info"));
        }
        Optional<UserInfo> userInfo = userInfoService.getUserInfoByToken(token);
        if (accountType == AccountType.STUDENT) {
            if (userInfo.isEmpty() || !userInfoService.isUserInfoComplete(userInfo.get())) {
                return ResponseEntity.status(204).build();
            }
        } else if (accountType == AccountType.TEACHER) {
            if (userInfo.isEmpty() || !userInfoService.isUserInfoComplete(userInfo.get())) {
                return ResponseEntity.ok(Map.of("message", "Notice this teacher has incomplete info."));
            }
            return ResponseEntity.ok(userInfo.get());
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

    @GetMapping("/profile-picture")
    public ResponseEntity<?> getProfilePicture(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid token or username"));
        }

        Optional<User> userOpt = userService.getUserByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }

        byte[] picture = userOpt.get().getProfilePicture();
        if (picture == null || picture.length != 300) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid profile picture length"));
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < picture.length; i += 3) {
            int r = picture[i] & 0xFF;
            int g = picture[i + 1] & 0xFF;
            int b = picture[i + 2] & 0xFF;
            sb.append(String.format("#%02X%02X%02X", r, g, b));
        }

        return ResponseEntity.ok(Map.of("profilePicture", sb.toString()));
    }

    @PostMapping("/profile-picture")
    public ResponseEntity<?> updateProfilePicture(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody Map<String, String> body) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid token or username"));
        }

        String data = body.get("profilePicture");
        if (data == null || data.length() != 600 || !data.matches("[0-9a-fA-F]+")) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid hex string"));
        }

        byte[] decoded = new byte[300];
        try {
            for (int i = 0; i < 300; i++) {
                decoded[i] = (byte) Integer.parseInt(data.substring(i * 2, i * 2 + 2), 16);
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid profilePicture format"));
        }

        Optional<User> userOpt = userService.getUserByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "User not found"));
        }

        User user = userOpt.get();
        user.setProfilePicture(decoded);
        userService.saveUser(user);

        return ResponseEntity.ok(Map.of("message", "Profile picture updated successfully"));
    }

}
