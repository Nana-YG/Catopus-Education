package org.catopus.contentserver.Utils;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

public class AuthUtil {


private boolean isTokenValid(String username, String token) {
    RestTemplate restTemplate = new RestTemplate();
    HttpHeaders headers = new HttpHeaders();
    headers.set("Username", username);
    headers.set("Token", token);

    HttpEntity<String> entity = new HttpEntity<>(headers);
    try {
        ResponseEntity<String> response = restTemplate.exchange(
                LOGIN_CHECK_URL,
                HttpMethod.GET,
                entity,
                String.class
        );
        return response.getStatusCode() == HttpStatus.OK;
    } catch (Exception e) {
        return false;
    }

}