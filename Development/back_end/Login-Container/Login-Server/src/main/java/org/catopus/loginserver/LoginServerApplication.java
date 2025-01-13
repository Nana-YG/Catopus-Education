package org.catopus.loginserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


@SpringBootApplication
@RestController
public class LoginServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(LoginServerApplication.class, args);
    }

    
    @GetMapping({"/login", "/login/"})
    public String hello() {
        return "Hello World\n";
    }

    @GetMapping({"/login/examination", "/login/examination/"})
    public String examination() {
        return "Examination API is working!\n";
    }

}
