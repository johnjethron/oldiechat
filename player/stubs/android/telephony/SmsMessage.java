// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
package android.telephony;

public class SmsMessage {
    public static SmsMessage createFromPdu(byte[] pdu) { throw new RuntimeException("stub"); }
    public int getStatus() { throw new RuntimeException("stub"); }
}
