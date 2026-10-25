// Package oggopus convierte audio Ogg Opus (las notas de voz de WhatsApp, .oga)
// a WAV PCM de 16 bits, un formato que Android 4.x reproduce sin códecs extra.
//
// La lectura del contenedor Ogg es Go puro; la decodificación usa libopus (cgo).
package oggopus

import (
	"bufio"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
)

// Lector de paquetes de un flujo Ogg (RFC 3533) con un solo flujo lógico.
type packetReader struct {
	r       *bufio.Reader
	serial  uint32
	started bool
	pending []byte // paquete incompleto que continúa en la página siguiente
	queue   [][]byte
	granule int64 // posición granular de la última página leída
	eos     bool
}

func newPacketReader(r io.Reader) *packetReader {
	return &packetReader{r: bufio.NewReader(r)}
}

func (p *packetReader) readPage() error {
	var hdr [27]byte
	if _, err := io.ReadFull(p.r, hdr[:]); err != nil {
		return err
	}
	if string(hdr[0:4]) != "OggS" || hdr[4] != 0 {
		return errors.New("oggopus: página Ogg no válida")
	}
	headerType := hdr[5]
	granule := int64(binary.LittleEndian.Uint64(hdr[6:14]))
	serial := binary.LittleEndian.Uint32(hdr[14:18])
	nsegs := int(hdr[26])

	lacing := make([]byte, nsegs)
	if _, err := io.ReadFull(p.r, lacing); err != nil {
		return err
	}
	size := 0
	for _, l := range lacing {
		size += int(l)
	}
	body := make([]byte, size)
	if _, err := io.ReadFull(p.r, body); err != nil {
		return err
	}

	if !p.started {
		p.serial = serial
		p.started = true
	} else if serial != p.serial {
		// otro flujo lógico (no ocurre en notas de voz): se ignora
		return nil
	}
	if headerType&0x01 == 0 && len(p.pending) > 0 {
		// la página no continúa el paquete anterior: se descarta lo incompleto
		p.pending = nil
	}
	if granule != -1 {
		p.granule = granule
	}

	off := 0
	for _, l := range lacing {
		p.pending = append(p.pending, body[off:off+int(l)]...)
		off += int(l)
		if l < 255 {
			p.queue = append(p.queue, p.pending)
			p.pending = nil
		}
	}
	if headerType&0x04 != 0 {
		p.eos = true
	}
	return nil
}

// next devuelve el paquete siguiente, o io.EOF al terminar el flujo.
func (p *packetReader) next() ([]byte, error) {
	for len(p.queue) == 0 {
		if p.eos {
			return nil, io.EOF
		}
		if err := p.readPage(); err != nil {
			if errors.Is(err, io.EOF) || errors.Is(err, io.ErrUnexpectedEOF) {
				return nil, io.EOF
			}
			return nil, err
		}
	}
	pkt := p.queue[0]
	p.queue = p.queue[1:]
	return pkt, nil
}

// Cabecera de identificación OpusHead (RFC 7845, sección 5.1)
type opusHead struct {
	channels   int
	preSkip    int
	inputRate  int
	mappingFam int
}

func parseOpusHead(pkt []byte) (opusHead, error) {
	if len(pkt) < 19 || string(pkt[0:8]) != "OpusHead" {
		return opusHead{}, errors.New("oggopus: no es un flujo Opus")
	}
	h := opusHead{
		channels:   int(pkt[9]),
		preSkip:    int(binary.LittleEndian.Uint16(pkt[10:12])),
		inputRate:  int(binary.LittleEndian.Uint32(pkt[12:16])),
		mappingFam: int(pkt[18]),
	}
	if h.channels < 1 || h.channels > 2 || h.mappingFam != 0 {
		return opusHead{}, fmt.Errorf("oggopus: %d canales / familia %d no soportados", h.channels, h.mappingFam)
	}
	return h, nil
}
