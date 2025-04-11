package org.catopus.loginserver.service;

import java.util.List;
import java.util.Optional;

import org.catopus.loginserver.model.CourseRegistration;
import org.catopus.loginserver.repository.CourseRepository;
import org.springframework.stereotype.Service;

@Service
public class CourseService {

    private final CourseRepository courseRepository;

    public CourseService(CourseRepository courseRepository) {
        this.courseRepository = courseRepository;
    }

    public CourseRegistration createCourse(CourseRegistration course) {
        if (courseRepository.existsByCourseCode(course.getCourseCode())) {
            throw new IllegalArgumentException("Course code already exists");
        }
        return courseRepository.save(course);
    }

    public Optional<CourseRegistration> findByCode(String courseCode) {
        return courseRepository.findByCourseCode(courseCode);
    }

    public Optional<CourseRegistration> findByNameAndCode(String name, String code) {
        return courseRepository.findByCourseNameAndCourseCode(name, code);
    }

    public void updateCourse(CourseRegistration course) {
        courseRepository.save(course);
    }

    public void addStudent(CourseRegistration course, String studentUsername) {
        String students = course.getStudents();
        String[] studentArray = students.isBlank() ? new String[]{} : students.split(",");

        // Prevent duplicate join
        for (String s : studentArray) {
            if (s.trim().equals(studentUsername)) {
                return;
            }
        }

        String updatedStudents = students.isBlank() ? studentUsername : students + "," + studentUsername;
        course.setStudents(updatedStudents);
        courseRepository.save(course);
    }

    public List<CourseRegistration> getCoursesByTeacher(String teacherUsername) {
        return courseRepository.findByTeacher(teacherUsername);
    }

    public List<CourseRegistration> getCoursesByStudent(String studentUsername) {
        return courseRepository.findAll().stream()
                .filter(course -> {
                    String students = course.getStudents();
                    return students != null && List.of(students.split("\\s*,\\s*")).contains(studentUsername);
                }).toList();
    }


}
