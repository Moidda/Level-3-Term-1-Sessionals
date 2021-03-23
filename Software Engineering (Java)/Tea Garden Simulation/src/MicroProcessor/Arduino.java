package MicroProcessor;

public class Arduino extends MicroProcessor {

    @Override
    public void IdAction() {
        getIdDevice().action();
    }

    @Override
    public void StorageAction() {
        getStorageDevice().storageAction();
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
        if(connectionType.equalsIgnoreCase("wifi") || connectionType.equalsIgnoreCase("gsm"))
            return true;
        return false;
    }
}
