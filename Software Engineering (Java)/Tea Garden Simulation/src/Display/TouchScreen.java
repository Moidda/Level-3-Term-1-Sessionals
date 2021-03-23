package Display;
import Controller.Controller;

public class TouchScreen implements DisplayDevice, Controller {
    @Override
    public void display() {
        System.out.println("Touch Screen Display");
    }

    @Override
    public void controlAction() {
        System.out.println("TouchScreen Control");
    }
}
