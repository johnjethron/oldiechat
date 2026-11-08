package wa

import (
	"context"
	"encoding/json"
	"errors"

	"go.mau.fi/whatsmeow/types"
)

// keepPerChat es el tope de mensajes guardados por chat; se borran los más viejos.
const keepPerChat = 50

// Tabla propia en session.db: los últimos mensajes de cada chat y, por chat, el
// nombre (grupos) y el último mensaje entregado por Messages (seen).
const schema = `
CREATE TABLE IF NOT EXISTS oc_message (
	seq    INTEGER PRIMARY KEY,
	chat   TEXT NOT NULL,
	id     TEXT NOT NULL,
	time   INTEGER NOT NULL,
	unread INTEGER NOT NULL,
	event  TEXT NOT NULL,
	UNIQUE (chat, id)
);
CREATE TABLE IF NOT EXISTS oc_chat (
	chat TEXT PRIMARY KEY,
	name TEXT NOT NULL DEFAULT '',
	seen INTEGER NOT NULL DEFAULT 0
);`

// Chat es una fila de la lista de chats.
type Chat struct {
	Chat   string `json:"chat"`
	Name   string `json:"name"`
	Time   int64  `json:"time"`
	Unread int    `json:"unread"`
}

// save guarda un mensaje y deja solo los keepPerChat más nuevos de su chat.
func (e *Engine) save(ev Event, unread bool) {
	data, _ := json.Marshal(ev)
	_, err := e.db.Exec(`INSERT OR IGNORE INTO oc_message (chat, id, time, unread, event) VALUES (?, ?, ?, ?, ?)`,
		ev.Chat, ev.ID, ev.Time, unread, data)
	if err == nil {
		_, err = e.db.Exec(`DELETE FROM oc_message WHERE chat = ? AND seq NOT IN
			(SELECT seq FROM oc_message WHERE chat = ? ORDER BY time DESC, seq DESC LIMIT ?)`, ev.Chat, ev.Chat, keepPerChat)
	}
	if err != nil {
		e.emit(Event{Type: "error", Chat: ev.Chat, ID: ev.ID, Error: "guardar mensaje: " + err.Error()})
	}
}

// Chats devuelve los chats de personas (kind "people") o de grupos ("groups"),
// del más reciente al más antiguo, con los mensajes recibidos sin consultar.
func (e *Engine) Chats(ctx context.Context, kind string) ([]Chat, error) {
	if kind != "people" && kind != "groups" {
		return nil, errors.New("wa: kind debe ser people o groups")
	}
	rows, err := e.db.QueryContext(ctx, `SELECT m.chat, IFNULL(c.name, ''), MAX(m.time),
		SUM(m.unread AND m.seq > IFNULL(c.seen, 0))
		FROM oc_message m LEFT JOIN oc_chat c ON c.chat = m.chat
		GROUP BY m.chat ORDER BY MAX(m.time) DESC`)
	if err != nil {
		return nil, err
	}
	var list []Chat
	for rows.Next() {
		var c Chat
		if err = rows.Scan(&c.Chat, &c.Name, &c.Time, &c.Unread); err != nil {
			rows.Close()
			return nil, err
		}
		if jid, _ := types.ParseJID(c.Chat); (jid.Server == types.GroupServer) == (kind == "groups") {
			list = append(list, c)
		}
	}
	rows.Close()
	for i := range list {
		jid, _ := types.ParseJID(list[i].Chat)
		if jid.Server != types.GroupServer {
			list[i].Name = e.personName(ctx, jid)
		} else if list[i].Name == "" {
			// el nombre del grupo se pide una vez al servidor y queda guardado
			if info, err := e.cli.GetGroupInfo(ctx, jid); err == nil {
				list[i].Name = info.Name
				e.setName(list[i].Chat, info.Name)
			}
		}
	}
	return list, rows.Err()
}

// Messages devuelve los mensajes de un chat llegados desde la consulta anterior
// (en la primera, todos los guardados), del más antiguo al más nuevo.
func (e *Engine) Messages(ctx context.Context, chat string) ([]Event, error) {
	var seen int64
	_ = e.db.QueryRowContext(ctx, `SELECT seen FROM oc_chat WHERE chat = ?`, chat).Scan(&seen)
	rows, err := e.db.QueryContext(ctx, `SELECT seq, event FROM oc_message WHERE chat = ? AND seq > ? ORDER BY time, seq`, chat, seen)
	if err != nil {
		return nil, err
	}
	var list []Event
	last := seen
	for rows.Next() {
		var ev Event
		var seq int64
		var data []byte
		if err = rows.Scan(&seq, &data); err == nil {
			last = max(last, seq)
			err = json.Unmarshal(data, &ev)
		}
		if err != nil {
			rows.Close()
			return nil, err
		}
		list = append(list, ev)
	}
	rows.Close()
	if err = rows.Err(); err != nil {
		return nil, err
	}
	_, err = e.db.ExecContext(ctx, `INSERT INTO oc_chat (chat, seen) VALUES (?, ?)
		ON CONFLICT (chat) DO UPDATE SET seen = MAX(seen, excluded.seen)`, chat, last)
	return list, err
}

// clearChats borra los chats y mensajes guardados (al cerrar la sesión).
func (e *Engine) clearChats() {
	_, _ = e.db.Exec(`DELETE FROM oc_message; DELETE FROM oc_chat`)
}

// setName guarda el nombre de un grupo.
func (e *Engine) setName(chat, name string) {
	_, _ = e.db.Exec(`INSERT INTO oc_chat (chat, name) VALUES (?, ?)
		ON CONFLICT (chat) DO UPDATE SET name = excluded.name`, chat, name)
}

// personName busca el nombre en la agenda del principal; si no está, el número.
func (e *Engine) personName(ctx context.Context, jid types.JID) string {
	c, _ := e.cli.Store.Contacts.GetContact(ctx, jid)
	for _, name := range []string{c.FullName, c.FirstName, c.BusinessName, c.PushName} {
		if name != "" {
			return name
		}
	}
	return "+" + jid.User
}

// phoneJID cambia un LID por el número de teléfono cuando se conoce.
func (e *Engine) phoneJID(ctx context.Context, jid types.JID) types.JID {
	if jid.Server == types.HiddenUserServer {
		if pn, err := e.cli.Store.LIDs.GetPNForLID(ctx, jid.ToNonAD()); err == nil && !pn.IsEmpty() {
			pn.Device = jid.Device
			return pn
		}
	}
	return jid
}
