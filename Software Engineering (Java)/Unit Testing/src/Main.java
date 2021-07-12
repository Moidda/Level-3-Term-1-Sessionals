import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter array length: ");
        int n = scanner.nextInt();
        for(int i = 0; i < n; i++) {
            System.out.print("Item " + (i+1) + " >");
            arrayList.add(scanner.nextInt());
        }

        Sorting sorting = new Sorting();
        arrayList = sorting.mergeSort(arrayList);
        System.out.print("Sorted List = ");
        System.out.println(arrayList);
    }

}
