package Server;

import Stock.StockMarket;
import Subscriber.Subscriber;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public static void main(String[] args) throws Exception {
        int port = 3333;
        ServerSocket ss = new ServerSocket(port);
        StockMarket stockMarket = new StockMarket();
        stockMarket.readStockFile(new File("src/test/stockList.txt"));

        Thread serverThread = new ServerThread(stockMarket);
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
                String clientName = "C_" + clientCount;
                Thread thread = new ClientHandler(socket, din, dout, clientName, stockMarket);
                stockMarket.addSubscriber(new Subscriber(clientName, din, dout));
                dout.writeUTF("Welcome!!");
                dout.writeUTF(stockMarket.toString());
                thread.start();
            }
            catch (Exception e) {
                System.out.println("Something went wrong on server side");
            }
        }
    }
}
