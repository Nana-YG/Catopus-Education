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

class TestSendMessageToServer {

    private ByteArrayOutputStream outContent;
    private Server testServer;

    @Test
    void testSendMessageToServer() throws Exception {

        testServer = new Server("TestServer", "DisconenctionTestServer", 8081);

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
        try (Socket clientSocket = new Socket("localhost", 8081);
             DataOutputStream out = new DataOutputStream(clientSocket.getOutputStream());
             DataInputStream in = new DataInputStream(clientSocket.getInputStream())) {

            // Send a mock message to the server
            String mockRequest = "Hi Server.";
            out.writeUTF(mockRequest); // Use writeUTF to send the request
            out.flush();

            // Read the response
            StringBuilder responseBuilder = new StringBuilder();
            while (true) {
                String response = in.readUTF(); // Use readUTF to match the server's writeUTF
                responseBuilder.append(response).append("\n");

                // Break the loop if the closing tag is found
                if (response.contains("</Message>")) {
                    break;
                }
            }

            // Assert the full response from the server
            testServer.stopServer();
            serverThread.interrupt();
            String Response = responseBuilder.toString();
            assertNotNull(Response, "Server did not respond");
            assertTrue(Response.contains("Hi Server"), "Unexpected response: " + Response);
        }
    }
}