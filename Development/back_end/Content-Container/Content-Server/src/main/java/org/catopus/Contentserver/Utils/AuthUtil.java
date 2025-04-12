package org.catopus.Contentserver.Utils;

import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

public class AuthUtil {

    private static final String LOGIN_CHECK_URL = "http://csrm-login:8080/login/check"; // Docker 内部地址

    private AuthUtil() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static boolean isTokenValid(String username, String token) {
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
            if (response.getStatusCode() == HttpStatus.OK
                    || response.getStatusCode() == HttpStatus.NO_CONTENT) {
                return true;
            }
        } catch (Exception e) {
            return false;
        }
        return false;
    }
}
