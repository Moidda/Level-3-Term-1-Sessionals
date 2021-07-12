import java.util.ArrayList;
import java.util.Collections;

public class Sorting {

    public ArrayList<Integer> Merge(ArrayList<Integer> list1, ArrayList<Integer> list2) {
        if(list1.isEmpty()) return list2;
        if(list2.isEmpty()) return list1;

        ArrayList<Integer> returnList = new ArrayList<Integer>();
        for(int i = 0, j = 0; i < list1.size() || j < list2.size(); ) {
            if(i == list1.size()) {
                returnList.add(list2.get(j));
                j++;
            }
            else if(j == list2.size()) {
                returnList.add(list1.get(i));
                i++;
            }
            else if(list1.get(i) < list2.get(j)) {
                returnList.add(list1.get(i));
                i++;
            }
            else {
                returnList.add(list2.get(j));
                j++;
            }
        }

        return returnList;
    }

    public ArrayList<Integer> mergeSort(ArrayList<Integer> list) {
        ArrayList<Integer> returnList;
        if(list.size() <= 2) {
            returnList = new ArrayList<Integer>(list);
            if(list.size() == 2 && list.get(0) > list.get(1))
                Collections.swap(returnList, 0, 1);

            return returnList;
        }

        int n = list.size();
        int mid = n/2;
        ArrayList<Integer> list1 = mergeSort(new ArrayList<Integer>(list.subList(0, mid+1)));
        ArrayList<Integer> list2 = mergeSort(new ArrayList<Integer>(list.subList(mid+1, n)));

        returnList = Merge(list1, list2);

        return returnList;
    }
}
