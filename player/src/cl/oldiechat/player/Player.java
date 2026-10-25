// Player.java - reproduce un archivo de audio con el MediaPlayer de Android.
//
// Se ejecuta desde la terminal con app_process (sin instalar una app):
//   CLASSPATH=player.jar app_process /system/bin cl.oldiechat.player.Player <archivo>
// Termina cuando acaba el audio; para detenerlo basta con terminar el proceso.

package cl.oldiechat.player;

import android.media.MediaPlayer;

import java.io.FileInputStream;

public class Player {
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("uso: Player <archivo>");
            System.exit(2);
        }

        // Se pasa el descriptor y no la ruta: mediaserver no tiene permiso para leer
        // los archivos privados de nchat
        FileInputStream in = new FileInputStream(args[0]);
        MediaPlayer player = new MediaPlayer();
        try {
            player.setDataSource(in.getFD());
            player.prepare();
            player.start();
            // Sin Looper no llegan los callbacks: se espera consultando el estado
            while (player.isPlaying()) {
                Thread.sleep(200);
            }
        } finally {
            player.release();
            in.close();
        }
    }
}
