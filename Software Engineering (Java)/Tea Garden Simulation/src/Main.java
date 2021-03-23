import Controller.*;
import Display.*;
import Internet.InternetConnection;
import Internet.InternetFactory;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        String controllerName = scanner.next();
        Controller controller = ControllerFactory.getController(controllerName);
        controller.controlAction();
    }

}
