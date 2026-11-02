// Firma mínima de android.telephony.SmsManager, solo para compilar SmsSend.java sin
// el SDK de Android. No se incluye en el .dex: en el teléfono se usa la clase real.

package android.telephony;

public final class SmsManager {
    public static SmsManager getDefault() { throw new RuntimeException("stub"); }
    public void sendTextMessage(String dest, String sc, String text, android.app.PendingIntent sent, android.app.PendingIntent delivery) { throw new RuntimeException("stub"); }
}
