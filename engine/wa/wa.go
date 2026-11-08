// Package wa es el núcleo de mensajería de OldieChat: una capa delgada sobre
// whatsmeow que expone solo lo que una interfaz minimalista necesita (vincular
// con código numérico, recibir y enviar texto, notas de voz listas para
// reproducir) como eventos simples, sin depender de nchat ni de una interfaz.
package wa

import (
	"bytes"
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	_ "github.com/mattn/go-sqlite3"
	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/proto/waE2E"
	"go.mau.fi/whatsmeow/store"
	"go.mau.fi/whatsmeow/store/sqlstore"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"
	waLog "go.mau.fi/whatsmeow/util/log"
	"google.golang.org/protobuf/proto"

	"oldiechat/engine/audio/oggopus"
)

// Event es lo que el motor informa a la interfaz. Solo se llenan los campos que
// corresponden a cada tipo.
type Event struct {
	Type     string  `json:"type"`              // connected, disconnected, logged_out, paired, message, audio_ready, error
	Chat     string  `json:"chat,omitempty"`    // JID del chat
	Sender   string  `json:"sender,omitempty"`  // JID de quien envía
	Name     string  `json:"name,omitempty"`    // nombre visible de quien envía
	ID       string  `json:"id,omitempty"`      // ID del mensaje
	Time     int64   `json:"time,omitempty"`    // segundos desde 1970
	FromMe   bool    `json:"from_me,omitempty"` // enviado desde esta cuenta
	Device   *uint16 `json:"device,omitempty"`  // dispositivo que envía (0 = principal)
	Text     string  `json:"text,omitempty"`    // texto del mensaje
	Audio    bool    `json:"audio,omitempty"`   // es una nota de voz o audio
	Seconds  uint32  `json:"seconds,omitempty"` // duración del audio
	Path     string  `json:"path,omitempty"`    // WAV listo para reproducir (audio_ready)
	Error    string  `json:"error,omitempty"`
	Chats    []Chat  `json:"chats,omitempty"`    // respuesta a chats
	Messages []Event `json:"messages,omitempty"` // respuesta a messages
}

// Engine es una sesión de mensajería guardada en un directorio de datos.
type Engine struct {
	cli     *whatsmeow.Client
	db      *sql.DB
	dataDir string
	emit    func(Event)
	qr      <-chan whatsmeow.QRChannelItem
}

// Open abre (o crea) la sesión guardada en dataDir. emit recibe los eventos
// desde otras goroutines y no debe bloquear mucho tiempo.
func Open(ctx context.Context, dataDir string, log waLog.Logger, emit func(Event)) (*Engine, error) {
	if log == nil {
		log = waLog.Noop
	}
	store.DeviceProps.Os = proto.String("OldieChat") // nombre en Dispositivos vinculados
	hs := store.DeviceProps.HistorySyncConfig        // historial inicial mínimo
	hs.FullSyncDaysLimit, hs.FullSyncSizeMbLimit = proto.Uint32(1), proto.Uint32(1)
	hs.InitialSyncMaxMessagesPerChat = proto.Uint32(keepPerChat)
	_ = os.RemoveAll(filepath.Join(dataDir, "media")) // audios de una sesión anterior que no cerró
	if err := os.MkdirAll(filepath.Join(dataDir, "media"), 0o700); err != nil {
		return nil, err
	}
	addr := fmt.Sprintf("file:%s?_foreign_keys=on&_busy_timeout=5000", filepath.Join(dataDir, "session.db"))
	db, err := sql.Open("sqlite3", addr)
	if err != nil {
		return nil, err
	}
	container := sqlstore.NewWithDB(db, "sqlite3", log.Sub("db"))
	if err = container.Upgrade(ctx); err != nil {
		return nil, err
	}
	if _, err = db.ExecContext(ctx, schema); err != nil {
		return nil, err
	}
	device, err := container.GetFirstDevice(ctx)
	if err != nil {
		return nil, err
	}
	e := &Engine{cli: whatsmeow.NewClient(device, log.Sub("client")), db: db, dataDir: dataDir, emit: emit}
	e.cli.AddEventHandler(e.handle)
	return e, nil
}

// LoggedIn indica si la sesión ya está vinculada a una cuenta.
func (e *Engine) LoggedIn() bool {
	return e.cli.Store.ID != nil
}

// Connect conecta con el servidor. Si la sesión no está vinculada, deja todo
// listo para llamar a PairPhone.
func (e *Engine) Connect(ctx context.Context) error {
	if !e.LoggedIn() {
		qr, err := e.cli.GetQRChannel(ctx)
		if err != nil {
			return err
		}
		e.qr = qr
	}
	return e.cli.Connect()
}

// PairPhone pide un código de 8 caracteres para vincular la cuenta del número
// indicado (solo dígitos, con código de país). En el teléfono principal se
// ingresa en Dispositivos vinculados > Vincular con número de teléfono.
func (e *Engine) PairPhone(ctx context.Context, phone string) (string, error) {
	if e.LoggedIn() {
		return "", errors.New("wa: la sesión ya está vinculada")
	}
	if e.qr == nil {
		return "", errors.New("wa: falta Connect antes de PairPhone")
	}
	// whatsmeow necesita el primer evento del canal QR antes de pedir el código
	select {
	case item := <-e.qr:
		if item.Event != "code" {
			return "", fmt.Errorf("wa: vinculación no disponible (%s)", item.Event)
		}
	case <-ctx.Done():
		return "", ctx.Err()
	}
	go func() {
		for item := range e.qr {
			if item.Event != "code" && item.Event != "success" {
				e.emit(Event{Type: "error", Error: "vinculación: " + item.Event})
			}
		}
	}()
	return e.cli.PairPhone(ctx, phone, true, whatsmeow.PairClientChrome, "Chrome (Linux)")
}

// Logout desvincula este dispositivo de la cuenta y borra la sesión guardada.
func (e *Engine) Logout(ctx context.Context) error {
	err := e.cli.Logout(ctx)
	if err == nil {
		e.clearChats()
	}
	return err
}

// SendText envía un mensaje de texto y devuelve su ID.
func (e *Engine) SendText(ctx context.Context, chat, text string) (string, error) {
	jid, err := types.ParseJID(chat)
	if err != nil {
		return "", err
	}
	resp, err := e.cli.SendMessage(ctx, jid, &waE2E.Message{Conversation: proto.String(text)})
	if err != nil {
		return "", err
	}
	e.save(Event{Type: "message", Chat: chat, ID: resp.ID, Time: resp.Timestamp.Unix(), FromMe: true, Text: text}, false)
	return resp.ID, nil
}

// Close desconecta la sesión y borra los audios descargados (como la terminal).
func (e *Engine) Close() {
	e.cli.Disconnect()
	_ = os.RemoveAll(filepath.Join(e.dataDir, "media"))
}

func (e *Engine) handle(evt any) {
	switch v := evt.(type) {
	case *events.Connected:
		e.emit(Event{Type: "connected"})
	case *events.Disconnected:
		e.emit(Event{Type: "disconnected"})
	case *events.LoggedOut:
		e.clearChats()
		e.emit(Event{Type: "logged_out"})
	case *events.PairSuccess:
		e.emit(Event{Type: "paired", Sender: v.ID.ToNonAD().String()})
	case *events.Message:
		if ev, ok := e.toEvent(v); ok {
			e.save(ev, !ev.FromMe)
			e.emit(ev)
			if ev.Audio {
				go e.prepareAudio(ev, v.Message.GetAudioMessage())
			}
		}
	case *events.GroupInfo:
		if v.Name != nil {
			e.setName(v.JID.String(), v.Name.Name)
		}
	case *events.HistorySync:
		for _, conv := range v.Data.GetConversations() {
			chat, err := types.ParseJID(conv.GetID())
			if err != nil {
				continue
			}
			for _, hm := range conv.GetMessages() {
				if m, err := e.cli.ParseWebMessage(chat, hm.GetMessage()); err == nil {
					if ev, ok := e.toEvent(m); ok {
						e.save(ev, false)
					}
				}
			}
		}
	}
}

var linkRe = regexp.MustCompile(`(?i)(https?://(www\.)?|www\.)([^/\s?#:]+)\S*`)

// toEvent convierte un mensaje en evento. Lo que no es texto ni audio va como
// etiqueta corta, igual que en la terminal; estados, canales y mensajes sin
// contenido visible (reacciones, avisos) no se emiten.
func (e *Engine) toEvent(m *events.Message) (Event, bool) {
	ctx := context.Background()
	if s := m.Info.Chat.Server; s == types.BroadcastServer || s == types.NewsletterServer {
		return Event{}, false
	}
	ev := Event{
		Type:   "message",
		Chat:   e.phoneJID(ctx, m.Info.Chat).String(),
		Sender: e.phoneJID(ctx, m.Info.Sender).ToNonAD().String(),
		Name:   m.Info.PushName,
		ID:     m.Info.ID,
		Time:   m.Info.Timestamp.Unix(),
		FromMe: m.Info.IsFromMe,
		Device: &m.Info.Sender.Device,
	}
	msg := m.Message
	kb := func(n uint64) string { return fmt.Sprintf(" %d KB", (n+1023)/1024) }
	caption := ""
	switch {
	case msg.GetConversation() != "":
		ev.Text = msg.GetConversation()
	case msg.GetExtendedTextMessage() != nil:
		ev.Text = msg.GetExtendedTextMessage().GetText()
	case msg.GetAudioMessage() != nil:
		ev.Audio = true
		ev.Seconds = msg.GetAudioMessage().GetSeconds()
	case msg.GetImageMessage() != nil:
		ev.Text, caption = "imagen"+kb(msg.GetImageMessage().GetFileLength()), msg.GetImageMessage().GetCaption()
	case msg.GetVideoMessage() != nil:
		v := msg.GetVideoMessage()
		ev.Text, caption = "video"+kb(v.GetFileLength()), v.GetCaption()
		if v.GetGifPlayback() {
			ev.Text = "gif" + kb(v.GetFileLength())
		}
	case msg.GetStickerMessage() != nil:
		ev.Text = "sticker"
	case msg.GetLocationMessage() != nil || msg.GetLiveLocationMessage() != nil:
		ev.Text = "ubicacion"
	case msg.GetContactMessage() != nil || msg.GetContactsArrayMessage() != nil:
		ev.Text = "contacto"
	case msg.GetDocumentMessage() != nil:
		d := msg.GetDocumentMessage()
		ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(d.GetFileName()), "."))
		ev.Text, caption = strings.TrimSpace("documento "+ext)+kb(d.GetFileLength()), d.GetCaption()
	default:
		return ev, false
	}
	if caption != "" {
		ev.Text += ": " + caption
	}
	ev.Text = linkRe.ReplaceAllString(ev.Text, "link $3")
	return ev, true
}

// prepareAudio descarga una nota de voz y la deja como WAV, que Android 4.1
// reproduce con MediaPlayer sin códecs extra.
func (e *Engine) prepareAudio(ev Event, audio *waE2E.AudioMessage) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()

	data, err := e.cli.Download(ctx, audio)
	if err != nil {
		e.emit(Event{Type: "error", Chat: ev.Chat, ID: ev.ID, Error: "descarga de audio: " + err.Error()})
		return
	}
	path := filepath.Join(e.dataDir, "media", ev.ID+".wav")
	if err = writeWAV(path, data); err != nil {
		e.emit(Event{Type: "error", Chat: ev.Chat, ID: ev.ID, Error: "conversión de audio: " + err.Error()})
		return
	}
	e.emit(Event{Type: "audio_ready", Chat: ev.Chat, ID: ev.ID, Path: path})
}

func writeWAV(path string, ogg []byte) error {
	tmp := path + ".part"
	f, err := os.Create(tmp)
	if err != nil {
		return err
	}
	if _, _, err = oggopus.ToWAV(bytes.NewReader(ogg), f); err != nil {
		f.Close()
		os.Remove(tmp)
		return err
	}
	if err = f.Close(); err != nil {
		os.Remove(tmp)
		return err
	}
	return os.Rename(tmp, path)
}
