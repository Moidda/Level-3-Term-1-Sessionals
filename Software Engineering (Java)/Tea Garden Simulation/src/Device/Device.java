package Device;

import MicroProcessor.MicroProcessor;
import WebServer.WebServer;
import Weight.Weight;

public class Device {

    private MicroProcessor microProcessor;
    private WebServer webServer;
    private Weight weight;

    public void Identification() {
        microProcessor.IdAction();
    }

    public void WeightMeasurement() {
        weight.action();
    }

    public void Storage() {
        microProcessor.StorageAction();
    }

    public void Display() {
        microProcessor.DisplayAction();
    }

    public void InternetConnection() {
        microProcessor.InternetConnectionAction();
    }

    public void Controller() {
        microProcessor.ControlAction();
    }

    public void ServerAction() {
        webServer.ServerAction();
    }

    public MicroProcessor getMicroProcessor() {
        return microProcessor;
    }

    public void setMicroProcessor(MicroProcessor microProcessor) {
        this.microProcessor = microProcessor;
    }

    public WebServer getWebServer() {
        return webServer;
    }

    public void setWebServer(WebServer webServer) {
        this.webServer = webServer;
    }

    public Weight getWeight() {
        return weight;
    }

    public void setWeight(Weight weight) {
        this.weight = weight;
    }
}
