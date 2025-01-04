package org.catopus;

import java.util.ArrayList;

public class ScienceClass {

    private int size;
    private Teacher teacher;
    private ArrayList<Student> students;

    // Constructor
    public ScienceClass(Teacher teacher) {
        this.teacher = teacher;
        this.size = 0;
        students = new ArrayList<Student>();
    }

    // Getters
    public int getSize() {
        return size;
    }

    public void addStudent(Student student) {
        students.add(student);
        size++;
    }

    public void removeStudent(Student student) {
        students.remove(student);
        size--;
    }



}
