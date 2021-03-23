package Storage;

public class StorageFactory {
    public static StorageDevice getStorageDevice(String deviceName) {
        if(deviceName.equalsIgnoreCase("SD")) {
            return new SDCard();
        }
        else {
            return null;
        }
    }
}
