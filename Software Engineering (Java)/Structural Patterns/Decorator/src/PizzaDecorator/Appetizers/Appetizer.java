package PizzaDecorator.Appetizers;

import PizzaDecorator.PizzaDecorator;
import Pizza.Pizza;

public abstract class Appetizer extends PizzaDecorator {

    public Appetizer(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    public abstract void description();
    public abstract int cost();
}
