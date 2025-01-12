package org.catopus.contentserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;


@SpringBootApplication
public class ContentServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ContentServerApplication.class, args);
    }


}
