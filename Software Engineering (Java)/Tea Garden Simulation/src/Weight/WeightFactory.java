package Weight;

public class WeightFactory {
    public static Weight getWeightDevice(String deviceName) {
        if(deviceName.equalsIgnoreCase("LoadSensor")) {
            return new LoadSensor();
        }
        else if(deviceName.equalsIgnoreCase("WeightModule")) {
            return new WeightModule();
        }
        else {
            return null;
        }
    }
}
