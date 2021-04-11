package Pizza;

public class VegPizza extends Pizza {
    @Override
    public void description() {
        System.out.print("Veg pizza");
    }

    @Override
    public int cost() {
        return 300;
    }
}
