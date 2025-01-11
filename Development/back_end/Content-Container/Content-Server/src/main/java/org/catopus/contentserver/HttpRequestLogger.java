package org.catopus.contentserver;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;

public class HttpRequestLogger {

    public static void main(String[] args) {
        int port = 8081;

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("Server is listening on port " + port);

            while (true) {
                Socket socket = serverSocket.accept();
                System.out.println("New client connected");

                // Handle the client in a new thread
                new Thread(() -> handleClient(socket)).start();
            }
        } catch (IOException ex) {
            System.out.println("Server exception: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    private static void handleClient(Socket socket) {
        try (InputStream input = socket.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(input));
             OutputStream output = socket.getOutputStream();
             PrintWriter writer = new PrintWriter(output)) {

            // Read the request
            StringBuilder requestBuilder = new StringBuilder();
            String line;
            while (!(line = reader.readLine()).isBlank()) {
                requestBuilder.append(line).append(System.lineSeparator());
            }

            // Save the request to a file
            saveRequestToFile(requestBuilder.toString());

            // Respond to the client
            String httpResponse = "HTTP/1.1 200 OK\r\n" +
                    "Content-Type: text/plain\r\n" +
                    "Content-Length: 13\r\n" +
                    "\r\n" +
                    "Hello, world!";
            writer.write(httpResponse);
            writer.flush();

        } catch (IOException ex) {
            System.out.println("Client handling exception: " + ex.getMessage());
            ex.printStackTrace();
        }
    }

    private static void saveRequestToFile(String request) {
        try {
            // Create a timestamped filename
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = "http_request_" + timestamp + ".txt";

            // Write the request to the file
            Files.write(Paths.get(fileName), request.getBytes());
            System.out.println("Request saved to " + fileName);

        } catch (IOException ex) {
            System.out.println("Error writing request to file: " + ex.getMessage());
            ex.printStackTrace();
        }
    }
}
