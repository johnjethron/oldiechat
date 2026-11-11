// Firma mínima, solo para compilar sin el SDK de Android (no va en el .dex).
// Interfaz oculta de Android: el receptor que se registra directo en el ActivityManager.
package android.content;

public interface IIntentReceiver {
    abstract class Stub extends android.os.Binder implements IIntentReceiver {}
}
