// oldiechat-engine es el motor de OldieChat como ejecutable independiente.
//
//	oldiechat-engine selftest [opciones]
//	    Comprueba DNS, HTTPS hacia el servidor de mensajería y la zona horaria.
//	    Termina con código 0 si todo funciona.
//
//	oldiechat-engine run --data <dir> [opciones]
//	    Mantiene la sesión y habla por stdin/stdout con líneas JSON (una por
//	    línea). Comandos que recibe:
//	        {"cmd":"pair","phone":"56912345678"}   -> {"type":"pair_code","text":"ABCD-EFGH"}
//	        {"cmd":"send","chat":"<jid>","text":"hola"} -> {"type":"sent","id":"..."}
//	        {"cmd":"quit"}
//	    Eventos que envía: ver engine/wa (connected, message, audio_ready, ...).
//
// Opciones comunes: --certs <pem> (certificados raíz), --dns 1.1.1.1:53,8.8.8.8:53,
// --tz America/Santiago, --log-level (en stderr: ERROR, WARN, INFO, DEBUG).
package main

import (
	"bufio"
	"context"
	"crypto/tls"
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	waLog "go.mau.fi/whatsmeow/util/log"

	"oldiechat/engine/netcfg"
	"oldiechat/engine/tz"
	"oldiechat/engine/wa"
)

const testHost = "web.whatsapp.com"

type options struct {
	data     string
	certs    string
	dns      string
	tz       string
	logLevel string
}

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	cmd := os.Args[1]
	fs := flag.NewFlagSet(cmd, flag.ExitOnError)
	var o options
	fs.StringVar(&o.data, "data", "", "directorio de datos de la sesión")
	fs.StringVar(&o.certs, "certs", "", "archivo PEM con certificados raíz")
	fs.StringVar(&o.dns, "dns", "", "servidores DNS ip:puerto separados por coma")
	fs.StringVar(&o.tz, "tz", "", "zona horaria, p. ej. America/Santiago")
	fs.StringVar(&o.logLevel, "log-level", "WARN", "nivel de registro en stderr")
	_ = fs.Parse(os.Args[2:])

	if err := setup(o); err != nil {
		fmt.Fprintln(os.Stderr, "oldiechat-engine:", err)
		os.Exit(1)
	}

	switch cmd {
	case "selftest":
		os.Exit(selftest(o))
	case "run":
		if o.data == "" {
			fmt.Fprintln(os.Stderr, "oldiechat-engine: falta --data")
			os.Exit(2)
		}
		if err := run(o); err != nil {
			fmt.Fprintln(os.Stderr, "oldiechat-engine:", err)
			os.Exit(1)
		}
	default:
		usage()
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "uso: oldiechat-engine selftest|run [--data dir] [--certs pem] [--dns ip:53,...] [--tz zona]")
	os.Exit(2)
}

func setup(o options) error {
	var servers []string
	if o.dns != "" {
		servers = strings.Split(o.dns, ",")
	}
	netcfg.UseNameservers(servers)
	if o.certs != "" {
		if err := netcfg.UseCertFile(o.certs); err != nil {
			return fmt.Errorf("certificados: %w", err)
		}
	}
	return tz.SetLocal(o.tz)
}

// selftest imprime una línea por prueba: "ok <prueba> <detalle>" o "FALLA ...".
func selftest(o options) int {
	failed := 0
	check := func(name string, fn func() (string, error)) {
		detail, err := fn()
		if err != nil {
			failed++
			fmt.Printf("FALLA %s: %v\n", name, err)
			return
		}
		fmt.Printf("ok %s %s\n", name, detail)
	}

	check("dns", func() (string, error) {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		addrs, err := net.DefaultResolver.LookupHost(ctx, testHost)
		if err != nil {
			return "", err
		}
		return testHost + " -> " + strings.Join(addrs, ","), nil
	})
	check("https", func() (string, error) {
		client := &http.Client{Timeout: 20 * time.Second}
		resp, err := client.Get("https://" + testHost + "/")
		if err != nil {
			return "", err
		}
		resp.Body.Close()
		version := map[uint16]string{tls.VersionTLS12: "TLS1.2", tls.VersionTLS13: "TLS1.3"}[resp.TLS.Version]
		return fmt.Sprintf("HTTP %d %s", resp.StatusCode, version), nil
	})
	check("tz", func() (string, error) {
		return time.Now().Format("2006-01-02 15:04 MST"), nil
	})

	if failed > 0 {
		return 1
	}
	return 0
}

// run mantiene la sesión y traduce entre líneas JSON y el motor.
func run(o options) error {
	var outMu sync.Mutex
	out := json.NewEncoder(os.Stdout)
	emit := func(v any) {
		outMu.Lock()
		defer outMu.Unlock()
		_ = out.Encode(v)
	}

	ctx := context.Background()
	eng, err := wa.Open(ctx, o.data, newStderrLog("engine", o.logLevel), func(e wa.Event) { emit(e) })
	if err != nil {
		return err
	}
	defer eng.Close()
	if err = eng.Connect(ctx); err != nil {
		return err
	}
	if !eng.LoggedIn() {
		emit(wa.Event{Type: "need_pairing"})
	}

	in := bufio.NewScanner(os.Stdin)
	in.Buffer(make([]byte, 64*1024), 1024*1024)
	for in.Scan() {
		var c struct {
			Cmd   string `json:"cmd"`
			Phone string `json:"phone"`
			Chat  string `json:"chat"`
			Text  string `json:"text"`
		}
		if err := json.Unmarshal(in.Bytes(), &c); err != nil {
			emit(wa.Event{Type: "error", Error: "json: " + err.Error()})
			continue
		}
		switch c.Cmd {
		case "pair":
			pctx, cancel := context.WithTimeout(ctx, time.Minute)
			code, err := eng.PairPhone(pctx, c.Phone)
			cancel()
			if err != nil {
				emit(wa.Event{Type: "error", Error: err.Error()})
			} else {
				emit(wa.Event{Type: "pair_code", Text: code})
			}
		case "send":
			id, err := eng.SendText(ctx, c.Chat, c.Text)
			if err != nil {
				emit(wa.Event{Type: "error", Chat: c.Chat, Error: err.Error()})
			} else {
				emit(wa.Event{Type: "sent", Chat: c.Chat, ID: id})
			}
		case "quit":
			return nil
		default:
			emit(wa.Event{Type: "error", Error: "comando desconocido: " + c.Cmd})
		}
	}
	return in.Err()
}

// stderrLog envía el registro de whatsmeow a stderr para no mezclarlo con el
// protocolo JSON de stdout.
type stderrLog struct {
	module string
	min    int
}

var logLevels = map[string]int{"DEBUG": 0, "INFO": 1, "WARN": 2, "ERROR": 3}

func newStderrLog(module, level string) waLog.Logger {
	min, ok := logLevels[strings.ToUpper(level)]
	if !ok {
		min = logLevels["WARN"]
	}
	return stderrLog{module: module, min: min}
}

func (l stderrLog) logf(level, msg string, args ...any) {
	if logLevels[level] < l.min {
		return
	}
	fmt.Fprintf(os.Stderr, "%s [%s %s] %s\n", time.Now().Format("15:04:05.000"), l.module, level, fmt.Sprintf(msg, args...))
}

func (l stderrLog) Debugf(msg string, args ...any) { l.logf("DEBUG", msg, args...) }
func (l stderrLog) Infof(msg string, args ...any)  { l.logf("INFO", msg, args...) }
func (l stderrLog) Warnf(msg string, args ...any)  { l.logf("WARN", msg, args...) }
func (l stderrLog) Errorf(msg string, args ...any) { l.logf("ERROR", msg, args...) }
func (l stderrLog) Sub(module string) waLog.Logger {
	return stderrLog{module: l.module + "/" + module, min: l.min}
}
