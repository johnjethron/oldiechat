// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
package android.graphics;

public class Bitmap {
    public enum Config { ARGB_8888 }
    public static Bitmap createBitmap(int width, int height, Config config) { throw new RuntimeException("stub"); }
    public void getPixels(int[] pixels, int offset, int stride, int x, int y, int width, int height) { throw new RuntimeException("stub"); }
}
