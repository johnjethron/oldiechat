package oggopus

/*
#cgo LDFLAGS: -lopus -lm
#include <opus/opus.h>
*/
import "C"

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"unsafe"
)

// Frecuencias de salida que admite el decodificador Opus
var decodeRates = []int{8000, 12000, 16000, 24000, 48000}

// outputRate elige la frecuencia válida más baja que no pierde calidad respecto
// de la original (las notas de voz de WhatsApp vienen a 16 kHz).
func outputRate(inputRate int) int {
	for _, r := range decodeRates {
		if inputRate > 0 && inputRate <= r {
			return r
		}
	}
	return 48000
}

// ToWAV lee Ogg Opus de r y escribe WAV PCM de 16 bits en w. Devuelve la
// frecuencia y los canales del audio escrito.
func ToWAV(r io.Reader, w io.WriteSeeker) (rate int, channels int, err error) {
	pr := newPacketReader(r)

	pkt, err := pr.next()
	if err != nil {
		return 0, 0, fmt.Errorf("oggopus: falta la cabecera: %w", err)
	}
	head, err := parseOpusHead(pkt)
	if err != nil {
		return 0, 0, err
	}
	if _, err = pr.next(); err != nil { // OpusTags
		return 0, 0, fmt.Errorf("oggopus: faltan los comentarios: %w", err)
	}

	rate = outputRate(head.inputRate)
	channels = head.channels

	var cerr C.int
	dec := C.opus_decoder_create(C.opus_int32(rate), C.int(channels), &cerr)
	if cerr != C.OPUS_OK || dec == nil {
		return 0, 0, fmt.Errorf("oggopus: opus_decoder_create: %d", int(cerr))
	}
	defer C.opus_decoder_destroy(dec)

	if err = writeWAVHeader(w, rate, channels, 0); err != nil {
		return 0, 0, err
	}

	// pre-skip y posición granular están en muestras de 48 kHz
	skip := head.preSkip * rate / 48000
	maxFrame := rate * 120 / 1000 // 120 ms, el paquete Opus más largo
	pcm := make([]int16, maxFrame*channels)
	out := make([]byte, 0, len(pcm)*2)
	var written int64 // muestras por canal escritas

	for {
		pkt, err = pr.next()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return 0, 0, err
		}
		if len(pkt) == 0 {
			continue
		}
		n := C.opus_decode(dec, (*C.uchar)(unsafe.Pointer(&pkt[0])), C.opus_int32(len(pkt)),
			(*C.opus_int16)(unsafe.Pointer(&pcm[0])), C.int(maxFrame), 0)
		if n < 0 {
			// paquete dañado: se sigue con el resto
			continue
		}
		samples := pcm[:int(n)*channels]
		if skip > 0 {
			drop := skip
			if drop > int(n) {
				drop = int(n)
			}
			samples = samples[drop*channels:]
			skip -= drop
		}

		// recorte final según la posición granular de la última página
		if pr.eos && pr.granule > 0 {
			total := (pr.granule - int64(head.preSkip)) * int64(rate) / 48000
			if remain := total - written; remain < int64(len(samples)/channels) {
				if remain < 0 {
					remain = 0
				}
				samples = samples[:remain*int64(channels)]
			}
		}

		out = out[:0]
		for _, s := range samples {
			out = binary.LittleEndian.AppendUint16(out, uint16(s))
		}
		if _, err = w.Write(out); err != nil {
			return 0, 0, err
		}
		written += int64(len(samples) / channels)
	}

	if _, err = w.Seek(0, io.SeekStart); err != nil {
		return 0, 0, err
	}
	if err = writeWAVHeader(w, rate, channels, written*int64(channels)*2); err != nil {
		return 0, 0, err
	}
	return rate, channels, nil
}

func writeWAVHeader(w io.Writer, rate, channels int, dataSize int64) error {
	var h [44]byte
	copy(h[0:4], "RIFF")
	binary.LittleEndian.PutUint32(h[4:8], uint32(36+dataSize))
	copy(h[8:16], "WAVEfmt ")
	binary.LittleEndian.PutUint32(h[16:20], 16)
	binary.LittleEndian.PutUint16(h[20:22], 1) // PCM
	binary.LittleEndian.PutUint16(h[22:24], uint16(channels))
	binary.LittleEndian.PutUint32(h[24:28], uint32(rate))
	binary.LittleEndian.PutUint32(h[28:32], uint32(rate*channels*2))
	binary.LittleEndian.PutUint16(h[32:34], uint16(channels*2))
	binary.LittleEndian.PutUint16(h[34:36], 16)
	copy(h[36:40], "data")
	binary.LittleEndian.PutUint32(h[40:44], uint32(dataSize))
	_, err := w.Write(h[:])
	return err
}
