package MicroProcessor;


public class RaspberryPi extends MicroProcessor {

    @Override
    public void IdAction() {
        getIdDevice().action();
    }

    @Override
    public void StorageAction() {
        System.out.println("Raspberry Pi internal storage");
    }

    @Override
    public void DisplayAction() {
        getDisplayDevice().display();
    }

    @Override
    public void InternetConnectionAction() {
        getConnectionDevice().connectionType();
    }

    @Override
    public void ControlAction() {
        getControllerDevice().controlAction();
    }

    @Override
    public boolean checkInternetConnection(String connectionType) {
        if (
            connectionType.equalsIgnoreCase("wifi") ||
            connectionType.equalsIgnoreCase("gsm") ||
            connectionType.equalsIgnoreCase("ethernet")
        )
            return true;
        return false;
    }
}
