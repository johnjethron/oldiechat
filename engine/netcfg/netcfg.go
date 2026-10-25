// Package netcfg configura DNS y certificados raíz sin depender de /etc.
//
// En Android sin root no se puede crear /etc/resolv.conf ni actualizar los
// certificados del sistema (que en Android 4.x están vencidos), y el resolvedor
// de Go sin /etc/resolv.conf consulta localhost:53, que no existe. Este paquete
// hace que todo el proceso use servidores DNS públicos y un paquete de
// certificados propio incluido en la app.
package netcfg

import (
	"context"
	"errors"
	"net"
	"os"
	"time"
)

// DefaultNameservers son los servidores DNS que se usan si no se indican otros.
var DefaultNameservers = []string{"1.1.1.1:53", "8.8.8.8:53", "9.9.9.9:53"}

// UseNameservers hace que net.DefaultResolver (y por lo tanto todo el proceso,
// incluido whatsmeow) consulte estos servidores en orden, ignorando
// /etc/resolv.conf. Cada servidor es "ip:puerto".
func UseNameservers(servers []string) {
	if len(servers) == 0 {
		servers = DefaultNameservers
	}
	list := append([]string(nil), servers...)
	net.DefaultResolver = &net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, _ string) (net.Conn, error) {
			d := net.Dialer{Timeout: 5 * time.Second}
			var lastErr error
			for _, s := range list {
				conn, err := d.DialContext(ctx, network, s)
				if err == nil {
					return conn, nil
				}
				lastErr = err
			}
			if lastErr == nil {
				lastErr = errors.New("netcfg: sin servidores DNS")
			}
			return nil, lastErr
		},
	}
}

// UseCertFile hace que crypto/x509 use este archivo PEM como certificados raíz
// del sistema. Debe llamarse antes de la primera conexión TLS del proceso, porque
// Go carga los certificados del sistema una sola vez.
func UseCertFile(pemPath string) error {
	if _, err := os.Stat(pemPath); err != nil {
		return err
	}
	return os.Setenv("SSL_CERT_FILE", pemPath)
}
