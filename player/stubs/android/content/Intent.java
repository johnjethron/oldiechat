// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
package android.content;

public class Intent {
    public Intent(String action) { throw new RuntimeException("stub"); }
    public String getAction() { throw new RuntimeException("stub"); }
    public byte[] getByteArrayExtra(String name) { throw new RuntimeException("stub"); }
}
