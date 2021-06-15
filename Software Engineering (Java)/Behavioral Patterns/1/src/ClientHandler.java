import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.Socket;
import java.util.Scanner;

public class ClientHandler extends Thread {
    final Socket socket;
    final DataInputStream din;
    final DataOutputStream dout;
    final String name;
    Scanner scanner;

    public ClientHandler(Socket socket, DataInputStream din, DataOutputStream dout, String name) {
        this.socket = socket;
        this.din = din;
        this.dout = dout;
        this.name = name;
        scanner = new Scanner(System.in);
    }

    // a client/user can subscribe/unsubscribe to a stock at any time
    @Override
    public void run() {
        String str;
        while(true) {
            try {
                // listening for any messages from the client
                str = din.readUTF();
                // client wishes to disconnect
                if (str.equalsIgnoreCase("stop"))
                    break;

                // client wants to subscribe to a stock package
                if (Character.toLowerCase(str.charAt(0)) == 's') {
                    System.out.println("Client " + name + " wants to subscribe to " + str.substring(2));
                }
                else if(Character.toLowerCase(str.charAt(0)) == 'u') {
                    System.out.println("Client " + name + " wants to unsubscribe from " + str.substring(2));
                }
                else {
                    System.out.println("Invalid client " + name + " request");
                }
            }
            catch (Exception e) {
                System.out.println("Ooops!!! Something went wrong T.T");
            }
        }

        // out of while loop
        // time to close this thread
        try {
            this.din.close();
            this.dout.close();
            this.socket.close();
            this.scanner.close();
        }
        catch (Exception e) {
            System.out.println("Ooops!!! Trouble closing din and dout");
        }
    }
}
