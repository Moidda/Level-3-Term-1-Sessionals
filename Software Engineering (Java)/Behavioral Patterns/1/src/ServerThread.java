import java.util.Scanner;

public class ServerThread extends Thread {
    @Override
    public void run() {
        Scanner scanner = new Scanner(System.in);
        String str;
        while(true) {
            str = scanner.nextLine();
            if(str.equalsIgnoreCase("stop"))
                break;
            if(Character.toLowerCase(str.charAt(0)) == 'i') {
                System.out.println("Server increased stock price: " + str);
            }
            else if(Character.toLowerCase(str.charAt(0)) == 'd') {
                System.out.println("Server decreased stock price: " + str);
            }
            else if(Character.toLowerCase(str.charAt(0)) == 'c') {
                System.out.println("Server changed stock amount: " + str);
            }
            else {
                System.out.println("Invalid server action");
            }
        }
    }
}
