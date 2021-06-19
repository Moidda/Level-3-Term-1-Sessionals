package Server;

import Stock.StockMarket;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.Socket;
import java.util.Scanner;

public class ClientHandler extends Thread {
    final Socket socket;
    final DataInputStream din;
    final DataOutputStream dout;
    final String name;
    StockMarket stockMarket;
    Scanner scanner;

    public ClientHandler(Socket socket, DataInputStream din, DataOutputStream dout, String name, StockMarket stk) {
        this.socket = socket;
        this.din = din;
        this.dout = dout;
        this.name = name;
        scanner = new Scanner(System.in);
        this.stockMarket = stk;
    }

    // a client/user can subscribe/unsubscribe to a stock at any time
    @Override
    public void run() {
        String str;
        while(true) {
            try {
                // listening for any messages from the client
                str = din.readUTF();
                if(str.isEmpty()) {
                    dout.writeUTF("");
                    continue;
                }

                // client wishes to disconnect
                if (str.equalsIgnoreCase("stop"))
                    break;

                /**
                 * Client-server interactions;
                 * Client requests something, server responds with the action and sends the corresponding
                 * action performed as a message back to the client
                 * */
                String message = "Invalid request";
                if (Character.toLowerCase(str.charAt(0)) == 's') {
                    System.out.println("Client " + name + " wants to subscribe to " + str.substring(2));
                    message = stockMarket.addSubscription(name, str.substring(2));
                    dout.writeUTF(message);
                }
                else if(Character.toLowerCase(str.charAt(0)) == 'u') {
                    System.out.println("Client " + name + " wants to unsubscribe from " + str.substring(2));
                    message = stockMarket.removeSubscription(name, str.substring(2));
                    dout.writeUTF(message);
                }
                else  {
                    dout.writeUTF(message);
                }
            }
            catch (Exception e) {
//                System.out.println("Oops!!! Something went wrong T.T");
                System.out.println(e.getMessage());
            }
        }

        try {
            this.din.close();
            this.dout.close();
            this.socket.close();
            this.scanner.close();
        }
        catch (Exception e) {
            System.out.println("Oops!!! Trouble closing din and dout");
            System.out.println(e.getMessage());
        }
    }
}
