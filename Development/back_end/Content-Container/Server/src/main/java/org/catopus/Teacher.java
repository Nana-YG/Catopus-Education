package org.catopus;

/**
 * Teacher class
 * Extends User calss
 */

public class Teacher extends User {

    // Constructor
    public Teacher() {
        super();
    }

    public Teacher(String name, String userID, User.Avatar avatar) {
        super(name, userID, avatar);
    }

    public ScienceClass createClass() {
        return new ScienceClass(this);
    }

}
