package Internet;

public class Wifi implements InternetConnection {
    @Override
    public void connectionType() {
        System.out.println("Wifi connected");
    }
}
