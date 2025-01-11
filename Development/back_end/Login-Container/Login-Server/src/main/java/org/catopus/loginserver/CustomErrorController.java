package org.catopus.loginserver;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Enumeration;

@RestController
@RequestMapping("/error")
public class CustomErrorController implements ErrorController {

    @RequestMapping(produces = MediaType.TEXT_PLAIN_VALUE)
    public String handleError(HttpServletRequest request, HttpServletResponse response) {
        StringBuilder requestDetails = new StringBuilder();

        // 获取HTTP方法和请求URI
        requestDetails.append("Method: ").append(request.getMethod()).append("\n");
        requestDetails.append("Request URI: ").append(request.getRequestURI()).append("\n");
        requestDetails.append("Protocol: ").append(request.getProtocol()).append("\n");
        requestDetails.append("Status: ").append(response.getStatus()).append("\n");

        // 获取请求头
        requestDetails.append("\nHeaders:\n");
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            requestDetails.append(headerName).append(": ").append(request.getHeader(headerName)).append("\n");
        }

        // 获取请求体
        requestDetails.append("\nBody:\n");
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                requestDetails.append(line).append("\n");
            }
        } catch (Exception e) {
            requestDetails.append("Error reading request body: ").append(e.getMessage());
        }

        // 将请求信息写入文件
        try {
            String logFilePath = "logs/request-log.txt";
            Files.createDirectories(Paths.get("logs"));
            Files.write(
                    Paths.get(logFilePath),
                    requestDetails.toString().getBytes(),
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
            );
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 返回纯文本
        return requestDetails.toString();
    }
}
