package Display;

public class DisplayFactory {
    public static DisplayDevice getDisplayDevice(String deviceName) {
        if(deviceName.equalsIgnoreCase("TouchScreen")) {
            return new TouchScreen();
        }
        else if(deviceName.equalsIgnoreCase("LED")) {
            return new LED();
        }
        else if(deviceName.equalsIgnoreCase("LCD")) {
            return new LCD();
        }
        else {
            return null;
        }
    }
}
