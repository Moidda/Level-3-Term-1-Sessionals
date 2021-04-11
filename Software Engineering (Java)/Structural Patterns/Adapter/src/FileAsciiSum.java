import java.io.*;
import java.util.Scanner;

public class FileAsciiSum {

    public void calculateAsciiSum(File file) {
        int sum = 0;
        try {
            FileReader fileReader = new FileReader(file);
            BufferedReader bufferedReader = new BufferedReader(fileReader);
            int x = 0;
            while ((x = bufferedReader.read()) != -1) {
                if((char)x != ' ')
                    sum += x;
            }
            System.out.println("Ascii sum = " + sum);
        }
        catch(Exception e) {
            System.out.println("Error opening file");
        }
    }
}
