// Firma mínima de android.media.MediaPlayer, solo para compilar Player.java sin el
// SDK de Android. No se incluye en el .dex: en el teléfono se usa la clase real.

package android.media;

public class MediaPlayer {
    public MediaPlayer() { throw new RuntimeException("stub"); }
    public void setDataSource(java.io.FileDescriptor fd) throws java.io.IOException { throw new RuntimeException("stub"); }
    public void prepare() throws java.io.IOException { throw new RuntimeException("stub"); }
    public void start() { throw new RuntimeException("stub"); }
    public boolean isPlaying() { throw new RuntimeException("stub"); }
    public void release() { throw new RuntimeException("stub"); }
}
