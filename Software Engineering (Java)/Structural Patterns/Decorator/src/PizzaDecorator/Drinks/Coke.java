package PizzaDecorator.Drinks;

import Pizza.Pizza;

public class Coke extends Drinks {

    public Coke(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    @Override
    public void description() {
        getDecoratedPizza().description();
        System.out.print(" with Coke");
    }

    @Override
    public int cost() {
        return getDecoratedPizza().cost()+10;
    }
}
