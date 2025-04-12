package org.catopus.Contentserver.Controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.InputStream;

@RestController
@RequestMapping("/content")
public class ContentController {

    // Example: /content/resource/chem-sample.rpy
    @GetMapping("/resource/{fileName:.+}")
    public ResponseEntity<StreamingResponseBody> downloadFile(
            @PathVariable String fileName,
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!isTokenValid(username, token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
        }

        try {
            // Locate file in classpath: static/game-scripts/...
            Resource resource = new ClassPathResource("static/game-scripts/" + fileName);

            if (!resource.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }

            StreamingResponseBody stream = outputStream -> {
                try (InputStream inputStream = resource.getInputStream()) {
                    byte[] buffer = new byte[8192];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                }
            };

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(stream);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}
