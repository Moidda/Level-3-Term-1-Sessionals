package Editor.Factory;

import Editor.Editor;

public class CPPFactory extends AbstractFactory {
    @Override
    public Editor getEditor() {
        Editor editor = new Editor();
        editor.setParser(new Parser.CPPparser());
        editor.setFont(new Aesthetics.Font.Monaco());
        editor.setColor(new Aesthetics.Color.Default());
        editor.setStyle(new Aesthetics.Style.Default());
        return editor;
    }
}
