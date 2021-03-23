package WebServer;

public class WebServerFactory {

    public WebServer getWebServer(String name) {
        if(name.equalsIgnoreCase("django")) {
            return new Django();
        }
        else if(name.equalsIgnoreCase("spring")) {
            return new Spring();
        }
        else if(name.equalsIgnoreCase("laravel")) {
            return new Laravel();
        }
        else {
            return null;
        }
    }
}
