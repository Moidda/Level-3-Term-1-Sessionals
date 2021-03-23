package Controller;

import Display.TouchScreen;

public class ControllerFactory {
    public static Controller getController(String controllerName) {
        if(controllerName.equalsIgnoreCase("Buttons")) {
            return new Buttons();
        }
        else if(controllerName.equalsIgnoreCase("TouchScreen")) {
            return new TouchScreen();
        }
        else {
            return null;
        }
    }
}
