package org.catopus.Contentserver.Security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import org.catopus.Contentserver.Utils.AuthUtil;

@Component
public class AuthInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String token = request.getHeader("Token");
        String username = request.getHeader("Username");

        if (AuthUtil.isTokenValid(username, token)) {
            return true;
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden: Invalid Token");
            return false;
        }
    }
}
