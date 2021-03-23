package MicroProcessor;

import Controller.Controller;
import Display.DisplayDevice;
import Identification.Identification;
import Internet.InternetConnection;
import Storage.StorageDevice;

public abstract class MicroProcessor {

    private Identification idDevice;
    private StorageDevice storageDevice;
    private DisplayDevice displayDevice;
    private InternetConnection connectionDevice;
    private Controller controllerDevice;

    public abstract void IdAction();
    public abstract void StorageAction();
    public abstract void DisplayAction();
    public abstract void InternetConnectionAction();
    public abstract void ControlAction();

    public abstract boolean checkInternetConnection(String connectionType);

    public void setIdDevice(Identification idDevice) {
        this.idDevice = idDevice;
    }

    public Identification getIdDevice() {
        return this.idDevice;
    }

    public StorageDevice getStorageDevice() {
        return storageDevice;
    }

    public void setStorageDevice(StorageDevice storageDevice) {
        this.storageDevice = storageDevice;
    }

    public DisplayDevice getDisplayDevice() {
        return displayDevice;
    }

    public void setDisplayDevice(DisplayDevice displayDevice) {
        this.displayDevice = displayDevice;
    }

    public InternetConnection getConnectionDevice() {
        return connectionDevice;
    }

    public void setConnectionDevice(InternetConnection connectionDevice) {
        this.connectionDevice = connectionDevice;
    }

    public Controller getControllerDevice() {
        return controllerDevice;
    }

    public void setControllerDevice(Controller controllerDevice) {
        this.controllerDevice = controllerDevice;
    }
}
