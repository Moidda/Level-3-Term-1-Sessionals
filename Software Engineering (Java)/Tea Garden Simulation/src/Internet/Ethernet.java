package Internet;

public class Ethernet implements InternetConnection {
    @Override
    public void connectionType() {
        System.out.println("Ethernet connected");
    }
}
