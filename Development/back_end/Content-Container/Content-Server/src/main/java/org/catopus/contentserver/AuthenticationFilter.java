package org.catopus.contentserver;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Component
public class AuthenticationFilter extends OncePerRequestFilter {

    private static final String USERNAME_HEADER = "Username";
    private static final String TOKEN_HEADER = "Token";

    // 使用服务名称和端口
    private static final String LOGIN_EXAMINATION_URL = "http://csrm-login:8080/login/examination";

    @Autowired
    private RestTemplate restTemplate;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String path = request.getRequestURI();

        if (path.startsWith("/game-scripts/")) {

            // 提取 Username 和 Token
            String username = request.getHeader(USERNAME_HEADER);
            String token = request.getHeader(TOKEN_HEADER);

            if (username == null || token == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Missing Username or Token");
                return;
            }

            try {
                // 构建带参数的 URL
                String url = LOGIN_EXAMINATION_URL
                        + "?username=" + URLEncoder.encode(username, StandardCharsets.UTF_8)
                        + "&token=" + URLEncoder.encode(token, StandardCharsets.UTF_8);

                // 发送 GET 请求
                ResponseEntity<String> examinationResponse = restTemplate.getForEntity(url, String.class);

                if (examinationResponse.getStatusCode() == HttpStatus.OK) {
                    // 验证成功，继续处理请求
                    filterChain.doFilter(request, response);
                } else {
                    // 验证失败，返回 401
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("Unauthorized");
                }
            } catch (Exception e) {
                // 处理异常，如 csrm-login 服务不可用
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Login service unreachable");
            }

        } else {
            // 非受保护路径，继续处理请求
            filterChain.doFilter(request, response);
        }
    }
}
