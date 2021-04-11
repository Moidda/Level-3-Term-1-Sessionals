import java.io.File;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        FileIntSum fileIntSum = new FileIntSum();
        fileIntSum.calculateSum(new File("src/input.txt"));

        fileIntSum = new Adapter(new FileAsciiSum());
        fileIntSum.calculateSum(new File("src/input.txt"));
    }
}
