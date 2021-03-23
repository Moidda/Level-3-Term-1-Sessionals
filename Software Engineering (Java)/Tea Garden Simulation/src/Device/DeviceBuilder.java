package Device;

import MicroProcessor.MicroProcessorFactory;
import WebServer.WebServerFactory;
import Weight.WeightFactory;

public abstract class DeviceBuilder {

    MicroProcessorFactory microProcessorFactory;
    WebServerFactory webServerFactory;

    DeviceBuilder() {
        microProcessorFactory = new MicroProcessorFactory();
        webServerFactory = new WebServerFactory();
    }

    /*
    * atmega32 with load sensor
    * */
    public Device buildSilverPackage(String InternetConnection, String WebFrameWork) {
        Device device = new Device();
        device.setMicroProcessor(microProcessorFactory.getMicroProcessor("ATMega32", InternetConnection));
        device.setWebServer(webServerFactory.getWebServer(WebFrameWork));
        device.setWeight(WeightFactory.getWeightDevice("loadSensor"));
        return device;
    }

    /*
    * arduino with weight module
    * */
    public Device buildGoldPackage(String InternetConnection, String WebFrameWork) {
        Device device = new Device();
        device.setMicroProcessor(microProcessorFactory.getMicroProcessor("Arduino", InternetConnection));
        device.setWebServer(webServerFactory.getWebServer(WebFrameWork));
        device.setWeight(WeightFactory.getWeightDevice("weightModule"));
        return device;
    }

    /*
    * raspberryPi with load sensor
    * */
    public Device buildDiamondPackage(String InternetConnection, String WebFrameWork) {
        Device device = new Device();
        device.setMicroProcessor(microProcessorFactory.getMicroProcessor("RaspberryPi", InternetConnection));
        device.setWebServer(webServerFactory.getWebServer(WebFrameWork));
        device.setWeight(WeightFactory.getWeightDevice("loadsensor"));
        return device;
    }

    /*
    * raspberryPi with weight module
    * */
    public Device buildPlatinumPackage(String InternetConnection, String WebFrameWork) {
        Device device = new Device();
        device.setMicroProcessor(microProcessorFactory.getMicroProcessor("RaspberryPi", InternetConnection));
        device.setWebServer(webServerFactory.getWebServer(WebFrameWork));
        device.setWeight(WeightFactory.getWeightDevice("weightModule"));
        return device;
    }
}
