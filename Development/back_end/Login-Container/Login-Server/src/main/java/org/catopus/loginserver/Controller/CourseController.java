package org.catopus.loginserver.Controller;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.catopus.loginserver.Model.AccountType;
import org.catopus.loginserver.Model.CourseRegistration;
import org.catopus.loginserver.Service.CourseRegistrationService;
import org.catopus.loginserver.Service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/course")
public class CourseController {

    private final CourseRegistrationService courseService;
    private final UserService userService;

    public CourseController(CourseRegistrationService courseService, UserService userService) {
        this.courseService = courseService;
        this.userService = userService;
    }

    // ✅ 老师创建课程接口
    @PostMapping("/createclass")
    public ResponseEntity<?> createCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody CourseRegistration course) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can create courses"));
        }

        // 检查课程名是否全局唯一
        if (courseService.findByClassNameAndJoinKey(course.getClassName(), course.getJoinKey()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Class name and joinKey already in use"));
        }

        course.setTeacher(username);
        course.setStudents("");
        course.setCurrent(true);

        CourseRegistration saved = courseService.save(course);
        return ResponseEntity.ok(saved);
    }

    // ✅ 学生加入课程接口
    @PostMapping("/joinclass")
    public ResponseEntity<?> joinCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody Map<String, String> body) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can join courses"));
        }

        String className = body.get("className");
        String joinKey = body.get("joinKey");

        if (className == null || joinKey == null || className.isBlank() || joinKey.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Missing className or joinKey"));
        }

        Optional<CourseRegistration> courseOpt = courseService.findByClassNameAndJoinKey(className, joinKey);

        if (courseOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "No matching course found"));
        }

        CourseRegistration course = courseOpt.get();

        String currentStudents = course.getStudents();

        List<String> existing = Arrays.asList(currentStudents.split(","));
        if (existing.contains(username)) {
            return ResponseEntity.badRequest().body(Map.of("error", "You have already joined this course"));
        }

        String updatedStudents = currentStudents.isBlank()
                ? username
                : currentStudents + "," + username;

        course.setStudents(updatedStudents);

        courseService.save(course);

        return ResponseEntity.ok(Map.of("message", "Joined course successfully", "className", className));
    }
}
