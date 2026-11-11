// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
package android.telephony;

public final class SmsManager {
    public static SmsManager getDefault() { throw new RuntimeException("stub"); }
    public java.util.ArrayList<String> divideMessage(String text) { throw new RuntimeException("stub"); }
    public void sendMultipartTextMessage(String dest, String sc, java.util.ArrayList<String> parts,
            java.util.ArrayList<android.app.PendingIntent> sent, java.util.ArrayList<android.app.PendingIntent> delivery) { throw new RuntimeException("stub"); }
}
