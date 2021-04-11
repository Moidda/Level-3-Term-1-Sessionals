package PizzaDecorator.Drinks;

import Pizza.Pizza;
import PizzaDecorator.PizzaDecorator;

public abstract class Drinks extends PizzaDecorator {

    public Drinks(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    public abstract void description();
    public abstract int cost();
}
