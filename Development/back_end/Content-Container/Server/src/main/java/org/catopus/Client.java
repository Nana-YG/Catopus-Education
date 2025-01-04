package org.catopus;

import java.io.*;
import java.net.*;
import java.util.Scanner;

/**
 * A TOY client
 * This Client class is for testing use only. There are several methods that can be used to test the Server
 */

// Client class
public class Client {

    //
    public static class ClientThread extends Thread {

        @Override
        public void run() {
            try {
                startClient();
            } catch (IOException e) {
                e.printStackTrace();
            }

        }

    }

    // Client process
    public static void startClient() throws IOException {

        try {
            Scanner scn = new Scanner(System.in);

            // getting localhost ip
            InetAddress ip = InetAddress.getByName("localhost");

            // establish the connection with server port 8080
            Socket s = new Socket(ip, 8080);

            // obtaining input and out streams
            DataInputStream in = new DataInputStream(s.getInputStream());
            DataOutputStream out = new DataOutputStream(s.getOutputStream());

            // the following loop performs the exchange of
            // information between client and client handler
            while (true)
            {
                try {
                    System.out.println(in.readUTF());
                } catch (EOFException e) {/* Do nothing */}

                // INPUT: Enter testing input

                String tosend;

                tosend = scn.nextLine();
//                tosend = "Hello Server, get me a feedback.";


                out.writeUTF(tosend);
                out.flush();

                // If client sends exit,close this connection
                // and then break from the while loop
                if(tosend.equals("Exit"))
                {
                    System.out.println("Closing this connection : " + s);
                    s.close();
                    System.out.println("Connection closed");
                    break;
                }

                // printing date or time as requested by client
                String received = "";
                try {
                    received = in.readUTF();
                } catch (IOException e) {/* Do nothing*/}
                System.out.println(received);
            }

            // closing resources
            scn.close();
            in.close();
            out.close();
            System.exit(0);
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws IOException {


        startClient();

//        Thread[] ClientThreads = new Thread[40];
//        for (int i = 0; i < 40; i++) {
//            ClientThreads[i] = (Thread) new ClientThread();
//            ClientThreads[i].start();
//        }


    }
}