// Updated CourseController.java
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

    // Create a new course(Teacher)
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

        course.setClassId(courseService.generateUniqueClassId());
        course.setTeacher(username);
        course.setStudents("");
        course.setCurrent(true);

        CourseRegistration saved = courseService.save(course);
        return ResponseEntity.ok(saved);
    }

    // Join a class(Student)
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

        String classId = body.get("classId");
        String joinKey = body.get("joinKey");

        if (classId == null || joinKey == null || classId.isBlank() || joinKey.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Missing classId or joinKey"));
        }

        Optional<CourseRegistration> courseOpt = courseService.findById(classId);

        if (courseOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Course not found"));
        }

        CourseRegistration course = courseOpt.get();
        if (!course.getJoinKey().equals(joinKey)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid join key"));
        }

        List<String> existing = Arrays.asList(course.getStudents().split(","));
        if (existing.contains(username)) {
            return ResponseEntity.badRequest().body(Map.of("error", "You have already joined this course"));
        }

        String updatedStudents = course.getStudents().isBlank()
                ? username
                : course.getStudents() + "," + username;

        course.setStudents(updatedStudents);
        courseService.save(course);

        return ResponseEntity.ok(Map.of(
                "message", "Joined course successfully",
                "classId", classId,
                "className", course.getClassName()
        ));
    }

    // Modify an existing class's details(Teacher)
    // Modifications are limited to className, joinKey, coursePackage, current.
    @PostMapping("/updateClass")
    public ResponseEntity<?> updateCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody CourseRegistration updatedCourse) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) == AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Student cannot update courses"));
        }

        Optional<CourseRegistration> courseOpt = courseService.findById(updatedCourse.getClassId());

        if (courseOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found"));
        }

        CourseRegistration existingCourse = courseOpt.get();

        if (!existingCourse.getTeacher().equals(username)) {
            return ResponseEntity.status(403).body(Map.of("error", "You can only update your own courses"));
        }

        existingCourse.setClassName(updatedCourse.getClassName());
        existingCourse.setJoinKey(updatedCourse.getJoinKey());
        existingCourse.setCoursePackage(updatedCourse.getCoursePackage());
        existingCourse.setCurrent(updatedCourse.isCurrent());

        CourseRegistration saved = courseService.save(existingCourse);
        return ResponseEntity.ok(saved);
    }

    // View all courses’ package for classes being created(Teacher)
    @GetMapping("/createdCoursePackages")
    public ResponseEntity<?> getCreatedCoursePackages(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can access this"));
        }

        List<String> packages = courseService.findAll().stream()
                .filter(course -> username.equals(course.getTeacher()))
                .map(course -> course.getCoursePackage().name())
                .distinct()
                .toList();

        return ResponseEntity.ok(Map.of("coursePackages", packages));
    }

    // View all course-name they joined(Student)
    @GetMapping("/joinedClassList")
    public ResponseEntity<?> getJoinedCourseList(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can access this"));
        }

        List<String> joinedClassNames = courseService.findAll().stream()
                .filter(course -> Arrays.stream(course.getStudents().split(","))
                .map(String::trim)
                .anyMatch(s -> s.equals(username)))
                .map(CourseRegistration::getClassName)
                .toList();

        return ResponseEntity.ok(Map.of("classNames", joinedClassNames));
    }

    // View all courses’ package for classes being joint(Student)
    @GetMapping("/joinedCoursePackages")
    public ResponseEntity<?> getJoinedCoursePackages(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can access this"));
        }

        List<String> packages = courseService.findAll().stream()
                .filter(course -> Arrays.stream(course.getStudents().split(","))
                .map(String::trim)
                .anyMatch(s -> s.equals(username)))
                .map(course -> course.getCoursePackage().name())
                .toList();

        return ResponseEntity.ok(Map.of("coursePackages", packages));
    }

    // View all student as list for a class(Teacher) 
    @GetMapping("/inClassStudents")
    public ResponseEntity<?> getStudentListByClassName(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestHeader("ClassId") String classId) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can access student lists"));
        }

        Optional<CourseRegistration> courseOpt = courseService.findById(classId);
        if (courseOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found"));
        }

        CourseRegistration course = courseOpt.get();

        if (!course.getTeacher().equals(username)) {
            return ResponseEntity.status(403).body(Map.of("error", "You can only view your own courses"));
        }

        List<String> studentList = course.getStudents() == null || course.getStudents().isBlank()
                ? List.of()
                : Arrays.stream(course.getStudents().split(","))
                        .map(String::trim)
                        .toList();

        return ResponseEntity.ok(Map.of("className", course.getClassName(), "studentList", studentList));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<?> handleEnumParseError(HttpMessageNotReadableException ex) {
        if (ex.getCause() instanceof InvalidFormatException formatException) {
            if (formatException.getTargetType().isEnum()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Invalid course package."));
            }
        }
        return ResponseEntity.badRequest().body(Map.of("error", "Invalid request body"));
    }
}
