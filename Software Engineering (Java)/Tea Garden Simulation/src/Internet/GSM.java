package Internet;

public class GSM implements InternetConnection{
    @Override
    public void connectionType() {
        System.out.println("GSM connected");
    }
}
