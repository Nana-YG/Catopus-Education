package org.catopus;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

import static org.junit.jupiter.api.Assertions.*;

class TestClientHandler {

    @Test
    void testSendMessage() throws Exception {
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        DataOutputStream outputStream = new DataOutputStream(outContent);

        ClientHandler clientHandler = new ClientHandler(null,null, null, null, outputStream);
        clientHandler.sendMessage("Hello!");

        assertTrue(outContent.toString().contains("Hello!"));
    }
}
