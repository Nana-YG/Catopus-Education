package org.catopus.contentserver.controller;

import java.io.IOException;
import java.nio.file.Files;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/content")
public class ContentController {

    private final RestTemplate restTemplate;

    public ContentController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @GetMapping("/fetch")
    public ResponseEntity<?> fetchContent(
            @RequestHeader(value = "Username", required = false) String username,
            @RequestHeader(value = "Token", required = false) String token) {

        if (username == null || token == null || username.isBlank() || token.isBlank()) {
            return ResponseEntity.badRequest().body("Username and Token required");
        }

        // Call csrm-login service to check authentication
        String loginServiceUrl = "http://csrm-login:8080/login/check"; // Ensure the correct internal service URL

        HttpHeaders headers = new HttpHeaders();
        headers.set("Username", username);
        headers.set("Token", token);

        HttpEntity<String> request = new HttpEntity<>(headers);
        ResponseEntity<String> loginResponse = restTemplate.exchange(loginServiceUrl, HttpMethod.GET, request, String.class);

        if (loginResponse.getStatusCode() != HttpStatus.OK) {
            return ResponseEntity.status(401).body("Unauthorized: Invalid token or username");
        }

        // If authentication is valid, return a text file
        try {
            Resource resource = new ClassPathResource("static/sample.txt"); // Ensure file exists in 'resources/static/'
            byte[] fileContent = Files.readAllBytes(resource.getFile().toPath());

            return ResponseEntity.ok()
                    .contentType(MediaType.TEXT_PLAIN)
                    .body(new String(fileContent));
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Error reading file");
        }
    }
}
