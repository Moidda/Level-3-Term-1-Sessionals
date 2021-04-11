import java.io.File;
import java.io.FileNotFoundException;
import java.util.InputMismatchException;
import java.util.Scanner;

public class FileIntSum {

    public void calculateSum(File file) {
        int sum = 0;
        try {
            Scanner scanner = new Scanner(file);
            while(scanner.hasNext()) {
                String str = scanner.next();
                try {
                    int x = Integer.parseInt(str);
                    sum += x;
                } catch( Exception e) {}
            }
        }
        catch(FileNotFoundException e) {
            System.out.println("Error opening file");
            e.printStackTrace();
            return;
        }
        System.out.println("Int sum = " + sum);
    }

}
