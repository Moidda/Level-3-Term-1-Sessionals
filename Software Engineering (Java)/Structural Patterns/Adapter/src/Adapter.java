import java.io.File;

public class Adapter extends FileIntSum {
    private FileAsciiSum fileAsciiSum;

    public Adapter(FileAsciiSum fileAsciiSum) {
        this.fileAsciiSum = fileAsciiSum;
    }

    @Override
    public void calculateSum(File file) {
        this.fileAsciiSum.calculateAsciiSum(file);
    }
}
