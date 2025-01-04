package org.catopus;

import java.io.IOException;
import java.time.ZonedDateTime;

/**
 * Heart of the server,
 * Sends heartbeat to System.out every 60 seconds
 */



public class Heart {

    private Server server;

    public Heart(Server server) {
        this.server = server;
    }

    public void startHeartBeat() throws IOException {
        Runnable startHeartBeat = new Runnable() {
            @Override
            public void run() {
                while (true) {
                    try {
                        ZonedDateTime now = ZonedDateTime.now();
                        HeartBeat heartBeat = new HeartBeat(server, now.toString());
                        heartBeat.sendHeartBest();
                        server.resetStatus();
                        Thread.sleep(60000); // 每 60 秒打印一次
                    } catch (InterruptedException e) {
                        System.out.println("<HeartBeat> Heartbeat thread interrupted.");
                        break;
                    }
                }
            }
        };
        Thread thread = new Thread(startHeartBeat);
        thread.start();
    }
}
