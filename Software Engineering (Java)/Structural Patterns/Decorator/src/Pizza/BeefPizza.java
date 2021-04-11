package Pizza;

public class BeefPizza extends Pizza {
    @Override
    public void description() {
        System.out.print("Beef Pizza");
    }

    @Override
    public int cost() {
        return 500;
    }
}
