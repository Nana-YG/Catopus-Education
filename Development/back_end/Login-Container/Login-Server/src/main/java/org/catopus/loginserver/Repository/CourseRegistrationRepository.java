package org.catopus.loginserver.Repository;

import java.util.Optional;

import org.catopus.loginserver.Model.CourseRegistration;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRegistrationRepository extends JpaRepository<CourseRegistration, Long> {

    // 查找课程：用于学生加入课程
    Optional<CourseRegistration> findByClassNameAndJoinKey(String className, String joinKey);

    // 根据 className 查找（因为你设置为全局唯一）
    Optional<CourseRegistration> findByClassName(String className);
}
