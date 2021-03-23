package Editor.Factory;

import Editor.Editor;

public class PythonFactory extends AbstractFactory {
    @Override
    public Editor getEditor() {
        Editor editor = new Editor();
        editor.setParser(new Parser.Pythonparser());
        editor.setFont(new Aesthetics.Font.Consolas());
        editor.setColor(new Aesthetics.Color.Default());
        editor.setStyle(new Aesthetics.Style.Default());
        return editor;
    }
}
