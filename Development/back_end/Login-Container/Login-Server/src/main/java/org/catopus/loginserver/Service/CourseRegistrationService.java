package org.catopus.loginserver.Service;

import java.util.List;
import java.util.Optional;

import org.catopus.loginserver.Model.CourseRegistration;
import org.catopus.loginserver.Repository.CourseRegistrationRepository;
import org.springframework.stereotype.Service;

@Service
public class CourseRegistrationService {

    private final CourseRegistrationRepository courseRepo;

    public CourseRegistrationService(CourseRegistrationRepository courseRepo) {
        this.courseRepo = courseRepo;
    }

    public CourseRegistration save(CourseRegistration course) {
        return courseRepo.save(course);
    }

    public Optional<CourseRegistration> findById(String courseId) {
        return courseRepo.findById(courseId);
    }

    public Optional<CourseRegistration> findByClassName(String className) {
        return courseRepo.findByClassName(className);
    }

    public List<CourseRegistration> findAll() {
        return courseRepo.findAll();
    }

    public boolean existsById(String courseId) {
        return courseRepo.existsById(courseId);
    }

    public String generateUniqueClassId() {
        String id;
        do {
            id = randomId();
        } while (courseRepo.existsById(id));
        return id;
    }

    private static final String ALPHANUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final int ID_LENGTH = 8;
    private static final java.security.SecureRandom random = new java.security.SecureRandom();

    private String randomId() {
        StringBuilder sb = new StringBuilder(ID_LENGTH);
        for (int i = 0; i < ID_LENGTH; i++) {
            sb.append(ALPHANUM.charAt(random.nextInt(ALPHANUM.length())));
        }
        return sb.toString();
    }
}
