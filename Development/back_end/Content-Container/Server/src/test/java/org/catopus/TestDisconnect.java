package org.catopus;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.io.*;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Simulate a real Server-Client communication to test Server's respond to messages, requests, etc.
 */

class TestDisconnect {

    private Server testServer;
    private ByteArrayOutputStream outContent;

    @Test
    void testDisconnect() throws Exception {

        testServer = new Server("TestServer", "DisconenctionTestServer", 8080);

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
        try (Socket clientSocket = new Socket("localhost", 8080);
             DataOutputStream out = new DataOutputStream(clientSocket.getOutputStream());
             DataInputStream in = new DataInputStream(clientSocket.getInputStream())) {

            // Disconnect from to the server
            String mockRequest = "EXIT";
            out.writeUTF(mockRequest); // Use writeUTF to send the request
            out.flush();
        } catch (UnknownHostException e) {
            fail("Client encountered an exception:\nServer does not exist: " + e.getMessage());
        } catch (IOException e) {
            fail("Client encountered an exception: " + e.getMessage());
        }

        // Assert the second heartbeat from the server
        Thread.sleep(62000);
        testServer.stopServer();
        serverThread.interrupt();
        String[] lines = outContent.toString().split("\n");
        assertNotNull(outContent.toString(), "Heartbeat not sent.");
        assertTrue(lines[lines.length - 4].contains(">>> Number of Clients: 0"), "Unexpected response: " + outContent.toString());

    }

}