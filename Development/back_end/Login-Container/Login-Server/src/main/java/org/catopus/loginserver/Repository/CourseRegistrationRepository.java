package org.catopus.loginserver.Repository;

import java.util.Optional;

import org.catopus.loginserver.Model.CourseRegistration;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRegistrationRepository extends JpaRepository<CourseRegistration, Long> {
    Optional<CourseRegistration> findByClassNameAndJoinKey(String className, String joinKey);
}
