package org.catopus.contentserver;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class AuthenticationFilter extends OncePerRequestFilter {

    //TODO: Token authentication
    private static final String AUTH_HEADER = "Authentication";
    private static final String AUTH_VALUE = "secret-word";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String path = request.getRequestURI();

        if (path.startsWith("/game-scripts/")) {
            String authHeader = request.getHeader(AUTH_HEADER);
            if (AUTH_VALUE.equals(authHeader)) {
                // 验证通过，继续处理请求
                filterChain.doFilter(request, response);
            } else {
                // 验证失败，返回 401 Unauthorized
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Unauthorized");
                return;
            }
        } else {
            // 非受保护路径，继续处理请求
            filterChain.doFilter(request, response);
        }
    }
}
