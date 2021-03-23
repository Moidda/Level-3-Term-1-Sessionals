package MicroProcessor;

import Controller.ControllerFactory;
import Display.DisplayFactory;
import Identification.IdentificationFactory;
import Internet.InternetFactory;
import Storage.StorageFactory;

public abstract class MicroProcessorBuilder {

    private String IdDevice;
    private String storageDevice;
    private String displayDevice;
    private String connectionDevice;
    private String controllerDevice;

    public MicroProcessor buildATMega32(String connectionDevice) {
        this.IdDevice = "RFID";
        this.storageDevice = "SD";
        this.displayDevice = "LCD";
        this.connectionDevice = connectionDevice;
        this.controllerDevice = "buttons";
        MicroProcessor microProcessor = new ATMega32();
        if(buildMicroprocessor("ATMega32", microProcessor)) {
            return microProcessor;
        }
        else {
            return null;
        }
    }

    public MicroProcessor buildArduino(String connectionDevice) {
        this.IdDevice = "RFID";
        this.storageDevice = "SD";
        this.displayDevice = "LED";
        this.connectionDevice = connectionDevice;
        this.controllerDevice = "buttons";
        MicroProcessor microProcessor = new Arduino();
        if(buildMicroprocessor("Arduino", microProcessor)) {
            return microProcessor;
        }
        else {
            return null;
        }
    }

    public MicroProcessor buildRaspberryPi(String connectionDevice) {
        this.IdDevice = "NFC";
        this.storageDevice = "default";
        this.displayDevice = "touchScreen";
        this.connectionDevice = connectionDevice;
        this.controllerDevice = "touchScreen";
        MicroProcessor microProcessor = new RaspberryPi();
        if(buildMicroprocessor("RaspberryPi", microProcessor)) {
            return microProcessor;
        }
        else {
            return null;
        }
    }

    private boolean buildMicroprocessor(String microprocessorName, MicroProcessor microProcessor) {
        microProcessor.setIdDevice(IdentificationFactory.getIdentification(IdDevice));
        microProcessor.setStorageDevice(StorageFactory.getStorageDevice(storageDevice));
        if(microProcessor.checkInternetConnection(connectionDevice)) {
            microProcessor.setConnectionDevice(InternetFactory.getInternetConnection(connectionDevice));
        }
        else {
            System.out.println(microprocessorName + " cannot support " + connectionDevice);
            return false;
        }
        microProcessor.setDisplayDevice(DisplayFactory.getDisplayDevice(displayDevice));
        microProcessor.setControllerDevice(ControllerFactory.getController(controllerDevice));
        System.out.println(microprocessorName + " built successfully");
        return true;
    }
}
