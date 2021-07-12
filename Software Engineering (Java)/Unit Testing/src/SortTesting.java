import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class SortTesting {
    private Sorting sorting;

    @BeforeEach
    public void setup() {
        sorting = new Sorting();
    }

    public boolean nextPermutation(ArrayList<Integer> arr) {
        if(arr.size() <= 1) return false;

        int last1 = arr.size() - 2;
        while(last1 >= 0) {
            if(arr.get(last1) < arr.get(last1+1)) break;
            last1--;
        }
        if(last1 < 0) return false;
        int last2 = arr.size() - 1;
        while(last2 > last1) {
            if(arr.get(last2) > arr.get(last1)) break;
            last2--;
        }
        if(last2 == last1) return false;

        Collections.swap(arr, last1, last2);
        for(int i = last1+1, j = arr.size() - 1; i < j; i++, j--)
            Collections.swap(arr, i, j);

        return true;
    }

    public int getRandomIntInRange(int min, int max) {
        Random random = new Random();
        return random.nextInt(max - min) + min;
    }

    public boolean isSorted(ArrayList<Integer> arrayList) {
        for(int i = 0; i+1 < arrayList.size(); i++) {
            if(arrayList.get(i) > arrayList.get(i+1))
                return false;
        }
        return true;
    }

    public boolean isEqualList(ArrayList<Integer> list1, ArrayList<Integer> list2) {
        ArrayList<Integer> newlist1 = new ArrayList<Integer>(list1);
        for(Integer integer: list2) {
            if (!newlist1.contains(integer)) return false;
            newlist1.remove(integer);
        }
        return true;
    }

    public void assertings(ArrayList<Integer> arrayList) {
        assertTrue(isSorted(sorting.mergeSort(arrayList)), "Test passed");
        assertTrue(isEqualList(arrayList, sorting.mergeSort(arrayList)), "Test passed");
    }

    public void printArrays(ArrayList<Integer> arrayList) {
        System.out.println("Before sorting: " + arrayList);
        System.out.println("After sorting : " + sorting.mergeSort(arrayList));
    }

    @Test
    @Order(1)
    @DisplayName("Blank list")
    public void blankList() {
        System.out.println("Blank List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(2)
    @DisplayName("Single element list")
    public void oneNumberList() {
        System.out.println("Single Element List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        arrayList.add(getRandomIntInRange(-100, 100));
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(3)
    @DisplayName("2 elements list")
    public void twoNumberList() {
        System.out.println("Two Element List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        arrayList.add(getRandomIntInRange(-100, 100));
        arrayList.add(getRandomIntInRange(-100, 100));
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(4)
    @DisplayName("n random elements list")
    public void randomSizeList() {
        System.out.println("Random size List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = getRandomIntInRange(3, 10);
        for(int i = 0; i < n; i++)
            arrayList.add(getRandomIntInRange(-100, 100));

        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(5)
    @DisplayName("n sorted element list")
    public void sortedAscendingList() {
        System.out.println("Sorted Ascending List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = getRandomIntInRange(3, 10);
        int x = getRandomIntInRange(-100, 100);
        for(int i = 0; i < n; i++) {
            x = getRandomIntInRange(x+1, x+100);
            arrayList.add(x);
        }
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(6)
    @DisplayName("n reverse sorted element list")
    public void sortedDescendingList() {
        System.out.println("Sorted Descending List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = getRandomIntInRange(3, 10);
        int x = getRandomIntInRange(-100, 100);
        for(int i = 0; i < n; i++) {
            x = getRandomIntInRange(x-100, x-1);
            arrayList.add(x);
        }
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(7)
    @DisplayName("n equal element list")
    public void allEqualList() {
        System.out.println("All Equal List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = getRandomIntInRange(3, 10);
        int x = getRandomIntInRange(-100, 100);
        for(int i = 0; i < n; i++) {
            arrayList.add(x);
        }
        printArrays(arrayList);
        assertings(arrayList);
        System.out.println("\n");
    }

    @Test
    @Order(8)
    @DisplayName("All possible permutations of 3 distinct elements")
    public void threeElementAllPermutation() {
        System.out.println("All permutations of 3 element List");
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = 3;
        int x = getRandomIntInRange(-100, 100);
        for(int i = 0; i < n; i++) {
            arrayList.add(x);
            x = getRandomIntInRange(x+1, x+100);
        }
        do {
            assertings(arrayList);
            printArrays(arrayList);
        }while(nextPermutation(arrayList));
        System.out.println("\n");
    }

    @Test
    @Order(9)
    @DisplayName("All possible permutations of n<=6 distinct elements")
    public void nElementAllPermutation() {
        ArrayList<Integer> arrayList = new ArrayList<Integer>();
        int n = getRandomIntInRange(4, 6);
        int x = getRandomIntInRange(-100, 100);
        for(int i = 0; i < n; i++) {
            arrayList.add(x);
            x = getRandomIntInRange(x+1, x+100);
        }
        do {
            assertings(arrayList);
        }while(nextPermutation(arrayList));
        System.out.println("All permutations of " + n + " element List");
        System.out.println("\n");
    }
}
