import Pizza.*;
import PizzaDecorator.Drinks.*;
import PizzaDecorator.Appetizers.*;

public class Main {
    public static void main(String[] args) {
        PizzaSelector pizzaSelector = new PizzaSelector();
        pizzaSelector.showMenu();
        pizzaSelector.selectMenu();
    }
}
