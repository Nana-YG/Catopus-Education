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
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.exc.InvalidFormatException;

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
    @PostMapping("/createClass")
    public ResponseEntity<?> createCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody CourseRegistration course) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) == AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Student cannot create courses"));
        }

        // 检查课程名是否全局唯一
        if (courseService.findByClassName(course.getClassName()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Class name already in use"));
        }

        course.setTeacher(username);
        course.setStudents("");
        course.setCurrent(true);

        CourseRegistration saved = courseService.save(course);
        return ResponseEntity.ok(saved);
    }

    // ✅ 学生加入课程接口
    @PostMapping("/joinClass")
    public ResponseEntity<?> joinCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody Map<String, String> body) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) == AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Teacher cannot join courses"));
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

    @PostMapping("/updateClass")
    public ResponseEntity<?> updateCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody CourseRegistration updatedCourse) {

        // 权限验证
        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) == AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Student cannot update courses"));
        }

        // 找到原课程（必须是该老师的）
        Optional<CourseRegistration> courseOpt = courseService.findById(updatedCourse.getId());
        if (courseOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found"));
        }

        CourseRegistration existingCourse = courseOpt.get();

        if (!existingCourse.getTeacher().equals(username)) {
            return ResponseEntity.status(403).body(Map.of("error", "You can only update your own courses"));
        }

        // Can update ClassName, JoinKey, CoursePackage, Current
        existingCourse.setClassName(updatedCourse.getClassName());
        existingCourse.setJoinKey(updatedCourse.getJoinKey());
        existingCourse.setCoursePackage(updatedCourse.getCoursePackage());
        existingCourse.setCurrent(updatedCourse.isCurrent());

        CourseRegistration saved = courseService.save(existingCourse);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/registeredCoursePackages")
    public ResponseEntity<?> getRegisteredCoursePackages(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        AccountType accountType = userService.getAccountTypeByUsername(username);
        List<CourseRegistration> allCourses = courseService.findAll();

        List<String> packages;

        if (accountType == AccountType.STUDENT) {
            // 学生：从 students 字段中匹配自己
            packages = allCourses.stream()
                    .filter(course -> {
                        String studentsStr = course.getStudents();
                        if (studentsStr == null || studentsStr.isBlank()) {
                            return false;
                        }
                        return Arrays.stream(studentsStr.split(","))
                                .map(String::trim)
                                .anyMatch(s -> s.equals(username));
                    })
                    .map(course -> course.getCoursePackage().name())
                    .toList();
        } else if (accountType == AccountType.TEACHER) {
            // 老师：匹配自己是 teacher
            packages = allCourses.stream()
                    .filter(course -> username.equals(course.getTeacher()))
                    .map(course -> course.getCoursePackage().name())
                    .distinct()
                    .toList();
        } else {
            return ResponseEntity.status(403).body(Map.of("error", "Unsupported account type"));
        }

        return ResponseEntity.ok(Map.of("coursePackages", packages));
    }

    @GetMapping("/inClassStudents")
    public ResponseEntity<?> getStudentListByClassName(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestHeader("ClassName") String className) {

        // 验证身份
        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can access student lists"));
        }

        // 根据唯一 className 查找课程
        Optional<CourseRegistration> courseOpt = courseService.findByClassName(className);
        if (courseOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found"));
        }

        CourseRegistration course = courseOpt.get();

        // 验证是否是该老师创建的课程
        if (!course.getTeacher().equals(username)) {
            return ResponseEntity.status(403).body(Map.of("error", "You can only view your own courses"));
        }

        // 解析学生名单
        String studentsStr = course.getStudents();
        List<String> studentList = studentsStr == null || studentsStr.isBlank()
                ? List.of()
                : Arrays.stream(studentsStr.split(","))
                        .map(String::trim)
                        .toList();

        return ResponseEntity.ok(Map.of(
                "className", course.getClassName(),
                "studentList", studentList
        ));
    }

    @GetMapping("/registeredClasses")
    public ResponseEntity<?> getRegisteredClassNames(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can access this"));
        }

        List<CourseRegistration> allCourses = courseService.findAll();

        List<String> classNames = allCourses.stream()
                .filter(course -> {
                    String studentsStr = course.getStudents();
                    if (studentsStr == null || studentsStr.isBlank()) {
                        return false;
                    }
                    return Arrays.stream(studentsStr.split(","))
                            .map(String::trim)
                            .anyMatch(s -> s.equals(username));
                })
                .map(CourseRegistration::getClassName)
                .toList();

        return ResponseEntity.ok(Map.of("classNames", classNames));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<?> handleEnumParseError(HttpMessageNotReadableException ex) {
        if (ex.getCause() instanceof InvalidFormatException formatException) {
            if (formatException.getTargetType().isEnum()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "error", "Invalid course package."));
            }
        }

        return ResponseEntity.badRequest().body(Map.of(
                "error", "Invalid request body"
        ));
    }

}
