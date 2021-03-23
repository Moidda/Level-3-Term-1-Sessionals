package Internet;

public class InternetFactory {
    public static InternetConnection getInternetConnection(String connectionName) {
        if(connectionName.equalsIgnoreCase("wifi")) {
            return new Wifi();
        }
        else if(connectionName.equalsIgnoreCase("gsm")) {
            return new GSM();
        }
        else if(connectionName.equalsIgnoreCase("Ethernet")) {
            return new Ethernet();
        }
        else {
            return null;
        }
    }
}
