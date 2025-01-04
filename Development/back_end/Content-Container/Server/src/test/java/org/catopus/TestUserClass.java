package org.catopus;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class TestUserClass {

    @Test
    void testSettersAndGetters() {
        User user = new User("John", "123", User.Avatar.FOX);

        assertEquals("John", user.getName());
        assertEquals("123", user.getUserID());
        assertEquals(User.Avatar.FOX, user.getAvatar());

        user.setName("Jane");
        assertEquals("Jane", user.getName());

        user.setUserID("456");
        assertEquals("456", user.getUserID());

        user.setAvatar(User.Avatar.CAT1);
        assertEquals(User.Avatar.CAT1, user.getAvatar());
    }

    @Test
    void testChangePassword() {
        User user = new User();
        char result = user.changePassword("newPassword");
        assertEquals('1', result); // Return 1 = Success
    }
}
