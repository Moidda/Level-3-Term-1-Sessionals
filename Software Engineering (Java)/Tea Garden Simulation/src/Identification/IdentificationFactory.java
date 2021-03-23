package Identification;

public class IdentificationFactory {
    public static Identification getIdentification(String deviceName) {
        if(deviceName.equalsIgnoreCase("RFID")) {
            return new RFID();
        }
        else if(deviceName.equalsIgnoreCase("NFC")) {
            return new NFC();
        }
        else {
            return null;
        }
    }
}
