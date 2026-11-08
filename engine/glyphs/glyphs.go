// Package glyphs adapta el texto al lugar donde se muestra: la pantalla del
// teléfono (reemplazos medidos en glyphs.txt) o un SMS (GSM de 7 bits, sin emoji).
package glyphs

import (
	"os"
	"strconv"
	"strings"

	"golang.org/x/text/unicode/norm"
)

// Table son los reemplazos de glyphs.txt: carácter -> texto (puede ser vacío).
type Table map[rune]string

// Load lee las líneas "R <hex> [texto]" de glyphs.txt; las demás se ignoran.
func Load(path string) (Table, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	t := Table{}
	for _, line := range strings.Split(string(data), "\n") {
		f := strings.SplitN(line, " ", 3)
		if len(f) < 2 || f[0] != "R" {
			continue
		}
		if cp, err := strconv.ParseUint(f[1], 16, 32); err == nil {
			t[rune(cp)] = strings.Join(f[2:], "")
		}
	}
	return t, nil
}

// Screen reemplaza los caracteres que la pantalla del teléfono no dibuja bien.
func (t Table) Screen(s string) string {
	var b strings.Builder
	for _, r := range s {
		if v, ok := t[r]; ok {
			b.WriteString(v)
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// gsm es el alfabeto GSM de 7 bits (03.38) con su tabla de extensión.
const gsm = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?" +
	"¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà^{}\\[~]|€"

var punct = strings.NewReplacer("“", `"`, "”", `"`, "„", `"`, "«", `"`, "»", `"`,
	"‘", "'", "’", "'", "‚", "'", "–", "-", "—", "-", "\t", " ")

// SMS deja el texto en GSM de 7 bits: quita las tildes que GSM no tiene
// (á -> a), quita emoji y todo lo demás sin reemplazo y junta los espacios.
// Devuelve "" si no queda nada (un mensaje solo de emoji no se reenvía).
func SMS(s string) string {
	var b strings.Builder
	for _, r := range punct.Replace(s) {
		if strings.ContainsRune(gsm, r) {
			b.WriteRune(r)
			continue
		}
		for _, d := range norm.NFKD.String(string(r)) {
			if strings.ContainsRune(gsm, d) {
				b.WriteRune(d)
			}
		}
	}
	out := b.String()
	for strings.Contains(out, "  ") {
		out = strings.ReplaceAll(out, "  ", " ")
	}
	return strings.TrimSpace(out)
}
