package Test;

import Stock.StockMarket;
import java.io.File;

public class Main {
    public static void main(String[] args) {
        StockMarket stockMarket = new StockMarket();
        stockMarket.readStockFile(new File("src/test/stockList.txt"));
        System.out.println(stockMarket);
    }
}
