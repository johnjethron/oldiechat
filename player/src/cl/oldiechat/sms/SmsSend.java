// SmsSend.java - envía un SMS en partes con el SmsManager de Android y espera el aviso de enviado.
//
// Se ejecuta como uid radio (1001) con app_process (sin instalar una app):
//   CLASSPATH=player.jar app_process /system/bin cl.oldiechat.sms.SmsSend <número> <texto>
// Escribe "enviado" (y luego "entregado", "no entregado <estado>" o "sin informe de entrega",
// esperando el informe hasta 10 s) o "error <código>" (2 = radio apagada, 4 = sin servicio)
// y sale con 1; sin aviso en 60 s escribe "sin aviso de envio" y sale con 3.
// Sin Context: los avisos se piden y se reciben directo al ActivityManager, a nombre de
// com.android.phone (uid 1001).

package cl.oldiechat.sms;

import android.app.PendingIntent;
import android.content.IIntentReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.ArrayList;

public class SmsSend {
    static final String SENT = "cl.oldiechat.sms.SENT", DELIVERED = "cl.oldiechat.sms.DELIVERED";
    static final Object lock = new Object();
    static int sent, error, delivered, status;

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("uso: SmsSend <número> <texto>");
            System.exit(2);
        }
        Object am = Class.forName("android.app.ActivityManagerNative").getMethod("getDefault").invoke(null);
        IIntentReceiver r = new IIntentReceiver.Stub() {
            public void performReceive(Intent i, int code, String d, Bundle e, boolean o, boolean s) { got(i, code); }
            public void performReceive(Intent i, int code, String d, Bundle e, boolean o, boolean s, int u) { got(i, code); }
        };
        IntentFilter f = new IntentFilter(SENT);
        f.addAction(DELIVERED);
        call(am, "registerReceiver", null, null, r, f, null);

        SmsManager sms = SmsManager.getDefault();
        ArrayList<String> parts = sms.divideMessage(args[1]);
        int n = parts.size();
        ArrayList<PendingIntent> si = new ArrayList<PendingIntent>(), di = new ArrayList<PendingIntent>();
        for (int k = 0; k < n; k++) {
            si.add(pending(am, SENT, k));
            di.add(pending(am, DELIVERED, k));
        }
        sms.sendMultipartTextMessage(args[0], null, parts, si, di);

        synchronized (lock) {
            waitFor(60000, n, true);
            if (error != 0) out("error " + error, 1);
            if (sent < n) out("sin aviso de envio", 3);
            System.out.println("enviado");
            waitFor(10000, n, false);
            out(status != 0 ? "no entregado " + status : delivered < n ? "sin informe de entrega" : "entregado", 0);
        }
    }

    static void got(Intent i, int code) {
        synchronized (lock) {
            if (SENT.equals(i.getAction())) {
                if (code == -1) sent++; else error = code;
            } else {
                byte[] pdu = i.getByteArrayExtra("pdu");
                int st = pdu == null ? 0 : SmsMessage.createFromPdu(pdu).getStatus();
                if (st < 0x20) delivered++; else if (st >= 0x40) status = st;   // 0x20-0x3f: la red sigue intentando
            }
            lock.notifyAll();
        }
    }

    static void waitFor(long ms, int n, boolean sending) throws InterruptedException {
        long end = System.currentTimeMillis() + ms;
        for (long left = ms; left > 0; left = end - System.currentTimeMillis()) {
            if (sending ? error != 0 || sent >= n : status != 0 || delivered >= n) return;
            lock.wait(left);
        }
    }

    static void out(String s, int code) {
        System.out.println(s);
        System.exit(code);
    }

    // PendingIntent de difusión a nombre de com.android.phone (el mismo uid que este proceso).
    static PendingIntent pending(Object am, String action, int code) throws Exception {
        Object s = call(am, "getIntentSender", 1, "com.android.phone", null, null, code,
                new Intent[] { new Intent(action) }, null, 0, null);
        Constructor<PendingIntent> c = PendingIntent.class.getDeclaredConstructor(Class.forName("android.content.IIntentSender"));
        c.setAccessible(true);
        return c.newInstance(s);
    }

    // Llama a IActivityManager.<name> con los argumentos dados; los que agregan versiones
    // nuevas de Android (userId, flags) van en 0.
    static Object call(Object am, String name, Object... a) throws Exception {
        for (Method m : Class.forName("android.app.IActivityManager").getMethods()) {
            Class<?>[] t = m.getParameterTypes();
            if (!m.getName().equals(name) || t.length < a.length) continue;
            Object[] v = new Object[t.length];
            for (int k = 0; k < t.length; k++) v[k] = k < a.length ? a[k] : t[k] == int.class ? (Object) 0 : null;
            return m.invoke(am, v);
        }
        throw new NoSuchMethodException(name);
    }
}
