package Storage;

public class SDCard implements StorageDevice {
    @Override
    public void storageAction() {
        System.out.println("SD card storage");
    }
}
