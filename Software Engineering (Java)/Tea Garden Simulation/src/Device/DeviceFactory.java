package Device;

public class DeviceFactory extends DeviceBuilder {

    public Device getDevice(String packageName, String InternetConnection, String WebFrameWork) {
        if(packageName.equalsIgnoreCase("silver")) {
            return buildSilverPackage(InternetConnection, WebFrameWork);
        }
        else if(packageName.equalsIgnoreCase("gold")) {
            return buildGoldPackage(InternetConnection, WebFrameWork);
        }
        else if(packageName.equalsIgnoreCase("diamond")) {
            return buildDiamondPackage(InternetConnection, WebFrameWork);
        }
        else if(packageName.equalsIgnoreCase("platinum")) {
            return buildPlatinumPackage(InternetConnection, WebFrameWork);
        }
        else {
            return null;
        }
    }
}
