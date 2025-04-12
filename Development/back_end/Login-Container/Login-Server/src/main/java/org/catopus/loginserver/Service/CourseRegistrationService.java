package org.catopus.loginserver.Service;

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

    public Optional<CourseRegistration> findByClassNameAndJoinKey(String className, String joinKey) {
        return courseRepo.findByClassNameAndJoinKey(className, joinKey);
    }

    public CourseRegistration save(CourseRegistration course) {
        return courseRepo.save(course);
    }
}
