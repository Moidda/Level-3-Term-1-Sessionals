package Display;

public class LED implements DisplayDevice{
    @Override
    public void display() {
        System.out.println("LED Display");
    }
}
