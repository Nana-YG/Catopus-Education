package org.catopus;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import static org.junit.jupiter.api.Assertions.*;

class TestHeart {

    @Test
    void testStartHeartBeat() throws InterruptedException {
        // Redirect System.out to catch output
        ByteArrayOutputStream outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        Server server = new Server("TestServer", "ID_Test", 8080);
        Heart heart = new Heart(server);

        // Start Heartbeat
        Thread heartBeatThread = new Thread(() -> {
            try {
                heart.startHeartBeat();
            } catch (Exception e) {
                fail("Heartbeat thread failed: " + e.getMessage());
            }
        });
        heartBeatThread.start();

        // One beat
        Thread.sleep(1500);
        assertTrue(outContent.toString().contains("<HeartBeat>"));
        heartBeatThread.interrupt();
    }
}
