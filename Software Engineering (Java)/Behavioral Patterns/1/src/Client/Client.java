package Client;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) throws Exception {
        Socket socket = new Socket("localhost", 3333);
        DataInputStream din = new DataInputStream(socket.getInputStream());
        DataOutputStream dout = new DataOutputStream(socket.getOutputStream());
        Scanner scanner = new Scanner(System.in);
        String str = "";

        System.out.println(din.readUTF());
        System.out.println(din.readUTF());

        while(!str.equalsIgnoreCase("stop")) {
            str = scanner.nextLine();
            dout.writeUTF(str);                             // request sth to the server
            System.out.println(din.readUTF());              // print the response of server to that request
        }

        din.close();
        dout.close();
        scanner.close();
        socket.close();
    }
}
