package org.catopus.loginserver.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.catopus.loginserver.model.AccountType;
import org.catopus.loginserver.model.CourseRegistration;
import org.catopus.loginserver.service.CourseService;
import org.catopus.loginserver.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/course")
public class CourseController {

    private final CourseService courseService;
    private final UserService userService;

    // For testing the Controller
    // @GetMapping("/ping")
    // public ResponseEntity<?> ping(@RequestHeader Map<String, String> headers) {
    //     headers.forEach((key, value) -> System.out.println(key + ": " + value));
    //     return ResponseEntity.ok("pong");
    // }
    public CourseController(CourseService courseService, UserService userService) {
        this.courseService = courseService;
        this.userService = userService;
    }

    // Create a new course--only teachers
    @PostMapping("/new")
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

        course.setTeacher(username);
        course.setStudents(""); // Initially empty
        CourseRegistration created = courseService.createCourse(course);

        return ResponseEntity.ok(created);
    }

    // Join a course--only students
    @PostMapping("/join")
    public ResponseEntity<?> joinCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody Map<String, String> payload) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can join courses"));
        }

        String courseName = payload.get("courseName");
        String courseCode = payload.get("courseCode");

        Optional<CourseRegistration> optionalCourse = courseService.findByNameAndCode(courseName, courseCode);
        if (optionalCourse.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found or code incorrect"));
        }

        CourseRegistration course = optionalCourse.get();
        courseService.addStudent(course, username);
        return ResponseEntity.ok(Map.of("message", "Successfully joined the course"));
    }

    // Update a course--only teachers
    @PutMapping("/update")
    public ResponseEntity<?> updateCourse(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token,
            @RequestBody CourseRegistration updatedCourse) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can update courses"));
        }

        Optional<CourseRegistration> existingOpt = courseService.findByCode(updatedCourse.getCourseCode());
        if (existingOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Course not found"));
        }

        CourseRegistration existing = existingOpt.get();

        if (!existing.getTeacher().equals(username)) {
            return ResponseEntity.status(403).body(Map.of("error", "You can only update your own courses"));
        }

        // Ensure critical fields are preserved
        updatedCourse.setId(existing.getId());
        updatedCourse.setTeacher(username); // Can't be changed by user input
        updatedCourse.setStudents(existing.getStudents()); // Preserve the student list

        // Persist the update
        courseService.updateCourse(updatedCourse);

        return ResponseEntity.ok(Map.of("message", "Course updated"));
    }

    @GetMapping("/teacher/mine")
    public ResponseEntity<?> getTeacherCourses(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.TEACHER) {
            return ResponseEntity.status(403).body(Map.of("error", "Only teachers can view their courses"));
        }

        return ResponseEntity.ok(
                courseService.getCoursesByTeacher(username).stream().map(course -> Map.of(
                "courseName", course.getCourseName(),
                "courseCode", course.getCourseCode(),
                "currentSemester", course.getCurrent(),
                "students", course.getStudents().isBlank()
                ? List.of() : List.of(course.getStudents().split("\\s*,\\s*"))
        ))
        );
    }

    @GetMapping("/student/mine")
    public ResponseEntity<?> getStudentCourses(
            @RequestHeader("Username") String username,
            @RequestHeader("Token") String token) {

        if (!userService.isTokenValidForUser(username, token)) {
            return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));
        }

        if (userService.getAccountTypeByUsername(username) != AccountType.STUDENT) {
            return ResponseEntity.status(403).body(Map.of("error", "Only students can view registered courses"));
        }

        return ResponseEntity.ok(
                courseService.getCoursesByStudent(username).stream().map(course -> Map.of(
                "courseName", course.getCourseName(),
                "courseCode", course.getCourseCode(),
                "teacher", course.getTeacher(),
                "currentSemester", course.getCurrent()
        ))
        );
    }

}
