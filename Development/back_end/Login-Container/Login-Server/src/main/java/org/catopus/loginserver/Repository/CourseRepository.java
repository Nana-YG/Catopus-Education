package org.catopus.loginserver.Repository;

import java.util.List;
import java.util.Optional;

import org.catopus.loginserver.Model.CourseRegistration;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository extends JpaRepository<CourseRegistration, Long> {

    Optional<CourseRegistration> findByCourseCode(String courseCode);

    Optional<CourseRegistration> findByCourseNameAndCourseCode(String courseName, String courseCode);

    boolean existsByCourseCode(String courseCode);

    List<CourseRegistration> findByTeacher(String teacherUsername);

}
