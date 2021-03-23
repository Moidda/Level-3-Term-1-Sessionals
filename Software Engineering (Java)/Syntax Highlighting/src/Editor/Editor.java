package Editor;

import Aesthetics.Color.Color;
import Aesthetics.Font.Font;
import Aesthetics.Style.Style;
import Parser.*;

public class Editor {

    private Parser parser;
    private Font font;
    private Style style;
    private Color color;

    public Parser getParser() {
        return parser;
    }

    public void setParser(Parser parser) {
        this.parser = parser;
    }

    public Font getFont() {
        return font;
    }

    public void setFont(Font font) {
        this.font = font;
    }

    public Style getStyle() {
        return style;
    }

    public void setStyle(Style style) {
        this.style = style;
    }

    public Color getColor() {
        return color;
    }

    public void setColor(Color color) {
        this.color = color;
    }

    @Override
    public String toString() {
        return
                "Editor Info:" + "\r\n" +
                parser.getParserName() + "\r\n" +
                font.getName() + "\r\n" +
                style.getName() + "\r\n" +
                color.getName() + "\r\n";
    }
}
