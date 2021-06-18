package Subscriber;

import Stock.SingleStock;

import javax.xml.crypto.Data;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.ArrayList;

public class Subscriber implements Observer {
    String name;
    DataInputStream dis;
    DataOutputStream dos;
    ArrayList<String> subscribedStocks;

    public Subscriber(String name, DataInputStream dis, DataOutputStream dos) {
        this.name = name;
        this.dis = dis;
        this.dos = dos;
        this.subscribedStocks = new ArrayList<String>();
    }

    void dosWrite(String str) {
        try {
            dos.writeUTF(str);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    public boolean isEquivalent(String name) {
        return name.equals(this.name);
    }

    public boolean isSubscribed(String stockName) {
        return subscribedStocks.contains(stockName);
    }

    public void subscribeStock(String stockName) {
        if(isSubscribed(stockName))
            dosWrite("You are already subscribed to this stock");
        else
            subscribedStocks.add(stockName);
    }

    public void unsubscribeStock(String stockName) {
        if(!isSubscribed(stockName))
            dosWrite("You are not subscribed to this stock");
        else
            subscribedStocks.remove(stockName);
    }

    @Override
    public void update(String message) {
        dosWrite(message);
    }
}
