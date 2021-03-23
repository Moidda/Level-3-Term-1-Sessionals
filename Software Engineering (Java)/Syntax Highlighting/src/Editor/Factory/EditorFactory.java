package Editor.Factory;

import Editor.Editor;

public class EditorFactory {

    public AbstractFactory getFactory(String languageName) {
        if(languageName.equalsIgnoreCase("c")) {
            return new Cfactory();
        }
        else if(languageName.equalsIgnoreCase("cpp")) {
            return new CPPFactory();
        }
        else if(languageName.equalsIgnoreCase("python")) {
            return new PythonFactory();
        }
        else {
            return null;
        }
    }

    public Editor getEditor(String languageName) {
        AbstractFactory abstractFactory = getFactory(languageName);
        try {
            return abstractFactory.getEditor();
        }
        catch (Exception e) {
            return null;
        }
    }
}
