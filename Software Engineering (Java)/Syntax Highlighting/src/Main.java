import Editor.Editor;
import Editor.Factory.EditorFactory;

import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter file name: ");
        String fileName = scanner.next();
        int index = fileName.lastIndexOf('.');

        String languageName = fileName.substring(index + 1);
        EditorFactory editorFactory = new EditorFactory();
        Editor editor = editorFactory.getEditor(languageName);
        System.out.println(editor);
    }
}
