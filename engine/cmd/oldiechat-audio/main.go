// oldiechat-audio convierte una nota de voz Ogg Opus a WAV.
//
// Uso: oldiechat-audio convert <entrada.oga> <salida.wav>
package main

import (
	"fmt"
	"os"

	"oldiechat/engine/audio/oggopus"
)

func main() {
	if len(os.Args) != 4 || os.Args[1] != "convert" {
		fmt.Fprintln(os.Stderr, "uso: oldiechat-audio convert <entrada.oga> <salida.wav>")
		os.Exit(2)
	}
	if err := convert(os.Args[2], os.Args[3]); err != nil {
		fmt.Fprintln(os.Stderr, "oldiechat-audio:", err)
		os.Exit(1)
	}
}

func convert(inPath, outPath string) error {
	in, err := os.Open(inPath)
	if err != nil {
		return err
	}
	defer in.Close()

	tmp := outPath + ".part"
	out, err := os.Create(tmp)
	if err != nil {
		return err
	}
	if _, _, err = oggopus.ToWAV(in, out); err != nil {
		out.Close()
		os.Remove(tmp)
		return err
	}
	if err = out.Close(); err != nil {
		os.Remove(tmp)
		return err
	}
	return os.Rename(tmp, outPath)
}
