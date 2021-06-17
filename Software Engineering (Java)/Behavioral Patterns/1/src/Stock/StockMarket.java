package Stock;

import Subscriber.Subscriber;
import java.util.ArrayList;

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

    @Override
    public void notifyObservers() {

    }
}
