import Pizza.*;
import PizzaDecorator.Appetizers.FrenchFries;
import PizzaDecorator.Appetizers.OnionRings;
import PizzaDecorator.Drinks.Coffee;
import PizzaDecorator.Drinks.Coke;

import java.util.Scanner;

public class PizzaSelector {

    public void showMenu() {
        System.out.println("-------------------------------Food Menu-------------------------------");
        System.out.println("            1. Beef Pizza with french fry");
        System.out.println("            2. Veg Pizza with onion rings");
        System.out.println("            3. Combo meal with Veg Pizza, French Fry and Coke");
        System.out.println("            4. Combo meal with Veg Pizza, Onion Rings and Coffee");
        System.out.println("            5. Beef Pizza");
    }

    public Pizza preparePizza1() {
        Pizza pizza = new FrenchFries(new BeefPizza());
        return pizza;
    }

    public Pizza preparePizza2() {
        Pizza pizza = new OnionRings(new VegPizza());
        return pizza;
    }

    public Pizza preparePizza3() {
        Pizza pizza = new Coke(new FrenchFries(new VegPizza()));
        return pizza;
    }

    public Pizza preparePizza4() {
        Pizza pizza = new Coffee(new OnionRings(new VegPizza()));
        return pizza;
    }

    public Pizza preparePizza5() {
        Pizza pizza = new BeefPizza();
        return pizza;
    }

    public void selectMenu() {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter your choice: ");
        int option = scanner.nextInt();

        Pizza pizza = null;
        switch (option) {
            case 1 -> pizza = preparePizza1();
            case 2 -> pizza = preparePizza2();
            case 3 -> pizza = preparePizza3();
            case 4 -> pizza = preparePizza4();
            case 5 -> pizza = preparePizza5();
            default -> {
                System.out.println("Invalid option");
                return;
            }
        }
        pizza.description();
        System.out.println("\nCost: " + pizza.cost());
    }
}
