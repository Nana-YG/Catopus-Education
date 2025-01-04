package org.catopus;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import static org.junit.jupiter.api.Assertions.*;

class TestHeartBeat {

    @Test
    void testToString() {
        Server server = new Server("TestServer", "TestID", 8080);
        HeartBeat heartBeat = new HeartBeat(server, "2024-11-23T12:00:00Z");

        String result = heartBeat.toString();
        assertTrue(result.contains("TestServer"));
        assertTrue(result.contains("2024-11-23T12:00:00Z"));
    }

    @Test
    void testSendHeartBeat() {
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        Server server = new Server("TestServer", "TestID", 8080);
        HeartBeat heartBeat = new HeartBeat(server, "2024-11-23T12:00:00Z");

        heartBeat.sendHeartBest();

        String output = outContent.toString();
        assertTrue(output.contains("TestServer"));
        assertTrue(output.contains("2024-11-23T12:00:00Z"));
    }
}
