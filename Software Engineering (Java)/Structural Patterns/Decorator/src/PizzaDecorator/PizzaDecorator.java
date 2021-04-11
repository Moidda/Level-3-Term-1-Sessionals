package PizzaDecorator;

import Pizza.Pizza;

public abstract class PizzaDecorator extends Pizza {
    private Pizza decoratedPizza;

    public PizzaDecorator(Pizza decoratedPizza) {
        this.decoratedPizza = decoratedPizza;
    }

    public Pizza getDecoratedPizza() {
        return this.decoratedPizza;
    }

    public abstract void description();
    public abstract int cost();
}
