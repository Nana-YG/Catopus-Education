package org.catopus;

import java.util.Dictionary;
import java.util.Hashtable;


/**
 * User class
 */


public class User {

    enum Avatar {
        EMPTY,
        SHARK,
        OCTOPUS,
        FOX,
        KUMA,
        CAT1,
        CAT2,
        CAT3,
        DOG1,
        DOG2,
        AOITORI
    }

    static private Dictionary<String, Integer> passwordBook = new Hashtable<>();
    private String name;
    private String userID;
    private String gameProgress;
    private Avatar avatar;

    // Constructor
    public User() {
        this.name = "";
        this.userID = "";
        this.gameProgress = "";
        this.avatar = Avatar.EMPTY;
    }

    public User(String name, String userID, Avatar avatar) {
        this.name = name;
        this.userID = userID;
        this.gameProgress = "";
        this.avatar = avatar;
    }

    // Setters
    public char setName(String name) {
        this.name = name;
        return '1';
    }

    public char setUserID(String userID) {
        this.userID = userID;
        return '1';
    }

    public char setAvatar(Avatar avatar) {
        this.avatar = avatar;
        return '1';
    }

    public char changePassword(String password) {
        // TODO Hash the password
        return '1';
    }

    // Getters
    public String getName() {
        return this.name;
    }

    public String getUserID() {
        return this.userID;
    }

    public String getGameProgress() {
        return this.gameProgress;
    }

    public Avatar getAvatar() {
        return this.avatar;
    }


}
