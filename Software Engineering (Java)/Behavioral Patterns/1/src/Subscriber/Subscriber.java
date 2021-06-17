package Subscriber;

import Stock.SingleStock;
import java.util.ArrayList;

public class Subscriber implements Observer {
    ArrayList<String> subscribedStocks;

    boolean isSubscribed(String stockName) {
        return subscribedStocks.contains(stockName);
    }

    void subscribeStock(String stockName) {
        if(isSubscribed(stockName)) {
            System.out.println("You are already subscribed to this stock");
            return;
        }
        subscribedStocks.add(stockName);
    }

    void unsubscribeStock(String stockName) {
        if(!isSubscribed(stockName)) {
            System.out.println("You are not subscribed to this stock");
            return;
        }
        subscribedStocks.remove(stockName);
    }

    void checkStock(String stockName) {

    }

    @Override
    public void update() {
        // called to notify this subscriber
    }
}
