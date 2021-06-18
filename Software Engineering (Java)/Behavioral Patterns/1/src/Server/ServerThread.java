package Server;

import Stock.StockMarket;

import java.util.ArrayList;
import java.util.Scanner;

public class ServerThread extends Thread {
    StockMarket stockMarket;

    public ServerThread(StockMarket stockMarket) {
        this.stockMarket = stockMarket;
    }

    @Override
    public void run() {
        Scanner scanner = new Scanner(System.in);
        String str;
        while(true) {
            str = scanner.nextLine();
            if(str.equalsIgnoreCase("stop")) {
                System.out.println("Server requests stopped.");
                break;
            }

            try {
                if (Character.toLowerCase(str.charAt(0)) == 'i') {
                    System.out.println("Server increased stock price: " + str);
                    String[] words = str.split(" ");
                    String stockName = words[1];
                    double amount = Double.parseDouble(words[2]);
                    stockMarket.increaseStockPrice(stockName, amount);
                }
                else if (Character.toLowerCase(str.charAt(0)) == 'd') {
                    System.out.println("Server decreased stock price: " + str);
                    String[] words = str.split(" ");
                    String stockName = words[1];
                    double amount = Double.parseDouble(words[2]);
                    stockMarket.decreaseStockPrice(stockName, amount);
                }
                else if (Character.toLowerCase(str.charAt(0)) == 'c') {
                    System.out.println("Server changed stock amount: " + str);
                    String[] words = str.split(" ");
                    String stockName = words[1];
                    int amount = Integer.parseInt(words[2]);
                    stockMarket.changeStockCount(stockName, amount);
                }
                else if(str.equalsIgnoreCase("print StockMarket")) {
                    System.out.println(stockMarket);
                }
                else {
                    System.out.println("Invalid server action");
                }
            }
            catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
    }
}
