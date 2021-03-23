import Controller.*;
import Device.Device;
import Device.DeviceFactory;
import Display.*;
import Internet.InternetConnection;
import Internet.InternetFactory;
import MicroProcessor.*;
import MicroProcessor.MicroProcessorBuilder;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        DeviceFactory deviceFactory = new DeviceFactory();

        while(true) {
            String packageName, connectionType, webFrameWork;
            System.out.println("Select package[Silver/ Gold/ Diamond/ Platinum]: ");
            packageName = scanner.next();
            if(packageName.equalsIgnoreCase("exit"))
                break;

            System.out.println("Select connection type[wifi/ gsm/ ethernet(Only for Diamond and platinum package)]: ");
            connectionType = scanner.next();
            System.out.println("Select web framework[django/ spring/ laravel]: ");
            webFrameWork = scanner.next();

            Device device = deviceFactory.getDevice(packageName, connectionType, webFrameWork);

            if(device == null) {
                continue;
            }

            device.WeightMeasurement();
            device.Identification();
            device.Storage();
            device.Display();
            device.InternetConnection();
            device.Controller();

            System.out.println("------------------------------------------------------------------------------------");
        }
    }

}
