// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
package android.text;

public class AndroidCharacter {
    public static final int EAST_ASIAN_WIDTH_FULL_WIDTH = 3;
    public static final int EAST_ASIAN_WIDTH_WIDE = 5;
    public static int getEastAsianWidth(char input) { throw new RuntimeException("stub"); }
}
