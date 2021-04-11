package PizzaDecorator.Appetizers;

import Pizza.Pizza;

public class OnionRings extends Appetizer {

    public OnionRings(Pizza decoratedPizza) {
        super(decoratedPizza);
    }

    @Override
    public void description() {
        getDecoratedPizza().description();
        System.out.print(" with onion rings");
    }

    @Override
    public int cost() {
        return getDecoratedPizza().cost()+100;
    }
}
