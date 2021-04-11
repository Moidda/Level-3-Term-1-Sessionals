package PizzaDecorator.Appetizers;

import Pizza.Pizza;

public class FrenchFries extends Appetizer {

    public FrenchFries(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    @Override
    public void description() {
        getDecoratedPizza().description();
        System.out.print(" with french fries");
    }

    @Override
    public int cost() {
        return getDecoratedPizza().cost()+100;
    }
}
