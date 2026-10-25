// GlyphProbe.java - mide en el teléfono cómo dibuja la terminal cada carácter.
//
// Se ejecuta con app_process (tools/glyphs.sh):
//   CLASSPATH=player.jar app_process /system/bin cl.oldiechat.probe.GlyphProbe A0-FFFF 10000-1FFFF
// Imprime una línea por carácter: "<hex> <ancho> <glifo> <avance>", donde ancho
// es el que usa TermOne Plus (0, 1 o 2), glifo es 1 si la fuente lo dibuja y 0 si
// sale el cuadro de carácter faltante, y avance es el ancho dibujado dividido por
// ancho * celda. TermOne Plus dibuja cada línea como texto corrido: un avance
// distinto de 1.00 corre visualmente todo lo que sigue en la línea.

package cl.oldiechat.probe;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.AndroidCharacter;

import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.util.Arrays;
import java.util.Locale;

public class GlyphProbe {
    private static final int SIZE = 48;
    private static final int BLACK = 0xff000000;
    private static final int WHITE = 0xffffffff;

    private static final Bitmap bitmap = Bitmap.createBitmap(SIZE, SIZE, Bitmap.Config.ARGB_8888);
    private static final Canvas canvas = new Canvas(bitmap);
    private static final Paint paint = new Paint();

    public static void main(String[] args) throws Exception {
        paint.setTypeface(Typeface.MONOSPACE);
        paint.setTextSize(24);
        paint.setColor(WHITE);

        // un carácter de uso privado que ninguna fuente tiene: su dibujo es el cuadro
        int[] missing = render(0xF8FE);
        int[] blank = render(' ');

        float cell = paint.measureText("a");

        BufferedWriter out = new BufferedWriter(new OutputStreamWriter(System.out, "UTF-8"));
        for (String range : args) {
            String[] parts = range.split("-");
            int first = Integer.parseInt(parts[0], 16);
            int last = Integer.parseInt(parts[parts.length - 1], 16);
            for (int cp = first; cp <= last; ++cp) {
                if (cp >= 0xD800 && cp <= 0xDFFF) continue;
                int width = termoneWidth(cp);
                int glyph = 0;
                float advance = 0;
                if (width > 0) {
                    String text = new String(Character.toChars(cp));
                    int[] pixels = render(cp);
                    glyph = (Arrays.equals(pixels, missing) || Arrays.equals(pixels, blank)) ? 0 : 1;
                    advance = paint.measureText(text) / (cell * width);
                }
                out.write(Integer.toHexString(cp).toUpperCase() + " " + width + " " + glyph + " "
                    + String.format(Locale.US, "%.2f", advance) + "\n");
            }
        }
        out.flush();
    }

    private static int[] render(int cp) {
        canvas.drawColor(BLACK);
        canvas.drawText(new String(Character.toChars(cp)), 4, 34, paint);
        int[] pixels = new int[SIZE * SIZE];
        bitmap.getPixels(pixels, 0, SIZE, 0, 0, SIZE, SIZE);
        return pixels;
    }

    // UnicodeTranscript.charWidth() de TermOne Plus en Android 4.x (API < 24)
    private static int termoneWidth(int cp) {
        if (cp > 31 && cp < 127) return 1;
        switch (Character.getType(cp)) {
            case Character.CONTROL:
            case Character.FORMAT:
            case Character.NON_SPACING_MARK:
            case Character.ENCLOSING_MARK:
                return 0;
        }
        if ((cp >= 0x1160 && cp <= 0x11FF) || (cp >= 0xD7B0 && cp <= 0xD7FF)) return 0;
        if (Character.charCount(cp) == 1) {
            int eaw = AndroidCharacter.getEastAsianWidth((char) cp);
            if (eaw == AndroidCharacter.EAST_ASIAN_WIDTH_FULL_WIDTH || eaw == AndroidCharacter.EAST_ASIAN_WIDTH_WIDE) {
                return 2;
            }
        } else {
            int plane = (cp >> 16) & 0xf;
            if (plane >= 1 && plane <= 3) return 2;
        }
        return 1;
    }
}
