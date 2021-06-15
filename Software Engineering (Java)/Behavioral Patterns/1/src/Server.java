import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;

public class Server {
    public static void main(String[] args) throws Exception {
        int port = 3333;
        ServerSocket ss = new ServerSocket(port);

        Thread serverThread = new ServerThread();
        serverThread.start();

        int clientCount = 0;
        while (true) {
            try {
                System.out.println("Waiting for a client ...");
                Socket socket = ss.accept();
                System.out.println("Connected to another client!!");
                clientCount++;

                DataInputStream din = new DataInputStream(socket.getInputStream());
                DataOutputStream dout = new DataOutputStream(socket.getOutputStream());
                Thread thread = new ClientHandler(socket, din, dout, "C_" + clientCount);
                thread.start();
            } catch (Exception e) {
                System.out.println("Something went wrong on server side");
            }
        }

//        ss.close();
    }
}
