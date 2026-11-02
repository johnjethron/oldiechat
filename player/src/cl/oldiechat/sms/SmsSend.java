// SmsSend.java - envía un SMS de una parte con el SmsManager de Android.
//
// Se ejecuta con root desde la terminal con app_process (sin instalar una app):
//   CLASSPATH=player.jar app_process /system/bin cl.oldiechat.sms.SmsSend <número> <texto>

package cl.oldiechat.sms;

import android.telephony.SmsManager;

public class SmsSend {
    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("uso: SmsSend <número> <texto>");
            System.exit(2);
        }
        SmsManager.getDefault().sendTextMessage(args[0], null, args[1], null, null);
    }
}
