package org.catopus.loginserver.Repository;

import java.util.Optional;

import org.catopus.loginserver.Model.CourseRegistration;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRegistrationRepository extends JpaRepository<CourseRegistration, String> {
    Optional<CourseRegistration> findByClassNameAndJoinKey(String className, String joinKey);
    Optional<CourseRegistration> findByClassName(String className);
    boolean existsById(String courseId);
}