package Editor.Factory;

import Editor.Editor;

public class Cfactory extends AbstractFactory {
    @Override
    public Editor getEditor() {
        Editor editor = new Editor();
        editor.setParser(new Parser.Cparser());
        editor.setFont(new Aesthetics.Font.CourierNew());
        editor.setColor(new Aesthetics.Color.Default());
        editor.setStyle(new Aesthetics.Style.Default());
        return editor;
    }
}
