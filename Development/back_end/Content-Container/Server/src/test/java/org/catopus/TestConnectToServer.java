package org.catopus;

import org.junit.jupiter.api.Test;
import java.io.*;
import java.net.Socket;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Simulate a real Server-Client communication to test Server's respond to messages, requests, etc.
 */

class TestConnectToServer {

    private ByteArrayOutputStream outContent;
    private Server testServer;

    @Test
    void testConnectToServer() throws Exception {

        testServer = new Server("TestServer", "DisconenctionTestServer", 8082);

        // Redirect System.out to capture server output
        outContent = new ByteArrayOutputStream();
        System.setOut(new PrintStream(outContent));

        // Run the server in a separate thread
        Thread serverThread = new Thread(() -> {
            try {
                testServer.startServer();
            } catch (Exception e) {
                fail("Server encountered an exception: " + e.getMessage());
            }
        });
        serverThread.start();

        // Allow the server to start
        Thread.sleep(1000);

        // Simulate a client connecting to the server
        Socket s = new Socket("localhost", 8082);

        // Assert the response from the server
        testServer.stopServer();
        serverThread.interrupt();
        BufferedReader reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
        String responseLine = reader.readLine();
        assertNotNull(responseLine, "Server did not respond");
        assertTrue(responseLine.contains("What do you want to say?"), "Unexpected response: " + responseLine);

    }

}
