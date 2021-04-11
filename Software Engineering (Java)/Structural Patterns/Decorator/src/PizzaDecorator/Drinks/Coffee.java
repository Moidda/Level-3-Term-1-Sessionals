package PizzaDecorator.Drinks;

import Pizza.Pizza;

public class Coffee extends Drinks {

    public Coffee(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    @Override
    public void description() {
        getDecoratedPizza().description();
        System.out.print(" with Coffee");
    }

    @Override
    public int cost() {
        return getDecoratedPizza().cost()+20;
    }
}
