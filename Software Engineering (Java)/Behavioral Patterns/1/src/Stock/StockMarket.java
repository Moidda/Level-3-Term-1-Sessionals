package Stock;

import Subscriber.Subscriber;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

/**
 * StockMarket at its core should have a list of stocks
 * Any of the stock can be edited
 *      prices may increase/decrease
 *      stock amount may increase/decrease
 *
 * Further, StockMarket is an observee/subject for subscribers to
 * observe. It implements the interface Subject and overrides
 * the notifyObservers() method.
 *
 * Whenever a stock has its content edited, all the users subscribed to
 * that stock should be notified appropriately
 */
public class StockMarket implements Subject {
    ArrayList<SingleStock> stocks;
    ArrayList<Subscriber> subscribers;

    public StockMarket() {
        this.stocks = new ArrayList<SingleStock>();
        this.subscribers = new ArrayList<Subscriber>();
    }

    SingleStock getSingleStock(String stockName) {
        for(SingleStock singleStock: stocks)
            if(singleStock.getName().equals(stockName))
                return singleStock;

        return null;
    }

    Subscriber getSubscriber(String subscriberName) {
        for(Subscriber s: this.subscribers)
            if(s.isEquivalent(subscriberName))
                return  s;

        return  null;
    }

    public void increaseStockPrice(String stockName, double amount) {
        SingleStock singleStock = this.getSingleStock(stockName);
        singleStock.setPrice(singleStock.getPrice() + amount);
        String message = "Price of " + stockName + " increased by " + amount;
        message += "\n\t" + singleStock;
        notifyObservers(stockName, message);
    }

    public void decreaseStockPrice(String stockName, double amount) {
        SingleStock singleStock = this.getSingleStock(stockName);
        singleStock.setPrice(singleStock.getPrice() - amount);
        String message = "Price of " + stockName + " decreased by " + amount;
        message += "\n\t" + singleStock;
        notifyObservers(stockName, message);
    }

    public void changeStockCount(String stockName, int amount) {
        SingleStock singleStock = this.getSingleStock(stockName);
        singleStock.setAmount(singleStock.getAmount() + amount);
        String message = "Count of " + stockName + " increased by " + amount;
        message += "\n\t" + singleStock;
        notifyObservers(stockName, message);
    }

    public void addStock(String stockName, int stockAmount, double stockPrice) {
        this.stocks.add(new SingleStock(stockName, stockAmount, stockPrice));
    }

    public void readStockFile(File file) {
        try {
            FileReader fileReader = new FileReader(file);
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            String line;
            while((line = bufferedReader.readLine()) != null) {
                String[] words = line.split(" ");
                String stockName = words[0];
                int stockAmount = Integer.parseInt(words[1]);
                double stockPrice = Double.parseDouble(words[2]);
                this.addStock(stockName, stockAmount, stockPrice);
            }
        }
        catch(Exception e) {
            System.out.println("Error processing file");
            System.out.println(e.getMessage());
        }
    }

    @Override
    public void notifyObservers(String stockName, String message) {
        for(Subscriber subscriber: subscribers)
            if(subscriber.isSubscribed(stockName))
                subscriber.update(message);
    }

    @Override
    public String toString() {
        String ret = "---STOCKMARKET---\n";
        ret += "StockList:\n";
        for(SingleStock singleStock: this.stocks) {
            ret += "\t" + singleStock + "\n";
        }
        return ret;
    }

    /********************************** SERVER-CLIENT functions ******************************/
    public void addSubscriber(Subscriber s) {
        this.subscribers.add(s);
    }

    public String addSubscription(String subscriberName, String stockName) {
        String ret = "";
        SingleStock stock = getSingleStock(stockName);
        if(stock == null) {
            ret = "No such stock available in market\n" + this;
        }
        else {
            Subscriber subscriber = getSubscriber(subscriberName);
            subscriber.subscribeStock(stockName);
            ret = "Subscription successful!";
        }
        return ret;
    }

    public String removeSubscription(String subscriberName, String stockName) {
        String ret = "";
        Subscriber subscriber = getSubscriber(subscriberName);
        if(!subscriber.isSubscribed(stockName)) {
            ret = "You are not subscribed to this stock";
        }
        else {
            ret = "Unsubscribed from " + stockName;
            subscriber.unsubscribeStock(stockName);
        }
        return ret;
    }
}
