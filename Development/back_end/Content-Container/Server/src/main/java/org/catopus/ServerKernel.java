package org.catopus;

import java.io.File;
import java.util.ArrayList;
import java.util.Scanner;

/**
 * !! GIVE UP THIS FILE: this will be implemented in C++
 *
 * Kernel of the entire Java program. Manages server instance(s).
 * Has three major jobs:
 *      1. Shell interface of the server, allows manual sudo operations on files
 *         and server instance(s).
 *      2. Handles file IO and file version control and synchronization.
 *      3. Checks life stage of service server, manages server lifecycle.
 *
 * ? What is ServerKernel
 *      The server kernel is a robust, well-debugged layer of the program that
 *      manages the service layer and directly interacts with OS and files.
 *      We will have to make sure that the kernel layer NEVER crashes.
 */


public class ServerKernel {

    public static ArrayList<Server> servers = new ArrayList<>();
    public static Scanner shScanner = new Scanner(System.in);
    private static File kernelFile;


// !!! Kernel core methods

    public static void exitKernel() {
        System.exit(0);
    }

    /**
     * Executes an input command line
     * Called by main()
     * @param inputLine
     * @return
     */
    public static int execLine(String inputLine) {

        // Returns 0 for empty line
        if (inputLine.isEmpty()) { return 0; }

        // Split the string
        String[] simpleCommands = inputLine.split(" ");

        if (simpleCommands[0].equals("server")) {
            cmdServer(simpleCommands);
        }

        return 0;
    }

// !!! Kernel Commands

    /**
     * Handles server commands:  >> server <*>
     * Called by execLine()
     * @param args
     */
    public static void cmdServer(String[] args) {

        // >> server create <name>
        if (args[1].equals("create")) {
            if (args.length < 3) {
                System.out.println("Usage: server <create> <name>");
                return;
            }
            createServer(args[2]);
        }

        // >> server start <index>
        if (args[1].equals("start")) {
            if (args.length < 3) {
                System.out.println("Usage: server <start> <index>");
            }
            try {
                Integer.parseInt(args[2]);
            } catch (NumberFormatException e) {
                System.out.println("Usage: server <start> <index>");
            }
            startServer(Integer.parseInt(args[2]));
        }

        // >> server ls
        if (args[1].equals("ls")) {
            if (servers.isEmpty()) {
                System.out.println("<EMPTY>");
                return;
            }
            System.out.printf("%-15s %-10s %-20s%n", "Index", "Server", "Stage");
            System.out.println("----------------------------------------------------");
            int i = 0;
            for (Server server : servers) {
                System.out.printf("%-15s %-10s %-20d%n", i++, server.name, server.stage);
            }
        }
    }



// !!! Server Operations

    /**
     * Creates and start a server by its name
     * @param serverName
     */
    public static void createServer(String serverName) {
        Server target = new Server(serverName, "ID_RandomID", 8080);
        servers.add(target);
        try {
            target.startServer();
            System.out.println("Server started:" + serverName);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            System.out.println("Server finally");
        }
    }


    /**
     * Start the server at given index
     * @param serverIndex
     */
    public static void startServer(int serverIndex) {

        Server target = servers.get(serverIndex);
        try {
            target.startServer();
            System.out.println("Server started:" + target.name);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            System.out.println("Server finally");
        }

    }


    public static void main(String[] args) {

        // kernelFile = new File(args[1]);

        Scanner scanner = shScanner;

        System.out.println("Type 'EXIT' to exit the server kernel：");

        while (true) {
            System.out.print(">> ");                    // Input Header
            String userInput = scanner.nextLine();      // Read a line

            // check for exit
            if ("exit".equalsIgnoreCase(userInput)) {
                exitKernel();
                break;
            }

            // handle input
            if (execLine(userInput) != 0) {
                System.out.println("Invalid command");
            }
        }

        // 关闭 Scanner
        scanner.close();
    }
}




