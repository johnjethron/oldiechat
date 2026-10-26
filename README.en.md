# OldieChat terminal

```
 o   o   o
  \_/ \_/
  ( ^_^ )
 OldieChat
```

[Español](README.md) · **English**

A terminal messaging client **compatible with WhatsApp** for old Android phones
(Android 4.x, ARMv7, rooted). It is the first stage of the OldieChat project; an
Android app in Java will follow.

It is based on [nchat](https://github.com/d99kris/nchat) and
[whatsmeow](https://github.com/tulir/whatsmeow), built as a static binary that
does not depend on Android's libraries.

> [!WARNING]
> **Unofficial client.** OldieChat is not affiliated with, associated with or
> endorsed by WhatsApp or Meta. Using unofficial clients goes against WhatsApp's
> terms of service, and **WhatsApp may suspend or ban your account**. Use it at
> your own risk. "WhatsApp" is a trademark of WhatsApp LLC and is only mentioned
> here to describe compatibility.

## Motivation

I made OldieChat for people who want to bring their old phones back to life and
give them a second chance, instead of leaving them in a drawer.

It is also my way of fighting doomscrolling: a simple phone that only has the
essentials for talking with the people I care about, without endless feeds or
notifications competing for my attention.

And I want to share something: I never imagined I would end up in the world of
software development. Today there are tools that let anyone with passion and
drive build things like this. I did it, and you can too.

## What it does

- Send and receive text messages, with nchat's interface adapted to a 3.5"
  screen and a touch keyboard.
- Pick a conversation by tapping its name in the list.
- Open the keyboard with a double tap on the input area.
- Show or hide archived chats with a shortcut.
- Listen to voice notes in the background: they are converted from Opus to WAV
  and played with Android's media player.
- Show times in the phone's time zone.
- Show black-and-white emoji with the Noto Emoji font, and replace the few that
  cannot be drawn properly with a short emoticon.

For now it does not send voice notes, images or files, and does not show images.

Tested on a **Samsung Galaxy Fame GT-S6810L** (Android 4.1.2, kernel 3.0.15,
Cortex-A9, 512 MB RAM, rooted with SuperSU).

## Requirements

**Phone**

- Android 4.x with an ARMv7 CPU and **root**.
- USB debugging enabled.
- [TermOne Plus](https://f-droid.org/packages/com.termoneplus/) (F-Droid), a
  maintained terminal that runs on Android 4.1.
- Optional: Nova Launcher or another launcher that supports shortcuts with a
  custom icon.

**Computer** (to install): Linux with `adb`. Building also needs Docker,
`qemu-user-static` and `binfmt-support`.

## Quick install (from Releases)

1. Download `oldiechat-terminal-<version>-armv7.tar.gz` and its `.sha256` from
   Releases.
2. Verify and extract:

   ```bash
   sha256sum -c oldiechat-terminal-0.1.0-armv7.tar.gz.sha256
   ```

   ```bash
   tar xzf oldiechat-terminal-0.1.0-armv7.tar.gz
   ```

3. Connect the phone over USB, unlock it and run:

   ```bash
   cd oldiechat-terminal-0.1.0-armv7 && ./install.sh
   ```

   Accept the SuperSU prompt if it appears. The script:

   - copies the program to `/data/local/tmp/oldiechat`;
   - installs the configuration (`key.conf`, `ui.conf`, `color.conf`,
     `glyphs.txt`, `guide.txt`), backing up any existing one as `.bak`;
   - creates `/system/etc/resolv.conf` with public DNS (`1.1.1.1` and `8.8.8.8`);
   - installs current root certificates in
     `/system/etc/ssl/certs/ca-certificates.crt`;
   - keeps an `.orig` copy of those two files if they already existed;
   - creates the `/system/bin/wsp` command;
   - copies the icon to `/sdcard/OldieChat/oldiechat.png`;
   - installs the emoji font in `/system/fonts/NotoEmoji-OldieChat.ttf` and adds
     it to `/system/etc/fallback_fonts*.xml`, keeping the original as `.orig`.
     The first time it asks you to **reboot the phone** (see
     [Emoji font](#emoji-font)).

   If there is a previous install in `/data/local/tmp/nchat`, its session is moved
   to the new path, so you do not need to link again.

   Optional variables: `NAMESERVERS="9.9.9.9"`,
   `CA_BUNDLE=/path/to/certificates.pem` and `ANDROID_SERIAL=...` when more than
   one phone is connected.

4. Link your account (first time only). Use a large terminal window on the
   computer so the QR code fits:

   ```bash
   adb shell
   ```

   ```
   su -c "TERM=screen-256color /data/local/tmp/oldiechat/oldiechat.sh --setup"
   ```

   Choose WhatsApp and scan the QR code from your main phone, under **Linked
   devices**. After scanning it can take a couple of minutes without showing
   anything; just wait.

## Setting up TermOne Plus

In **Preferences**:

| Option | Value |
| --- | --- |
| Terminal type | `screen-256color` (required for taps) |
| Send mouse events | on |
| Control key | Volume down |
| Fn key | Volume up |
| Font size | whatever is readable for you (10–12 on 3.5") |
| Close window on exit | on |
| Back button behavior | Sends TAB to terminal (Back = go back) |

Then close TermOne Plus completely and open it again.

To open OldieChat, type `wsp` in TermOne Plus.

## Home screen shortcut with icon (Nova Launcher)

TermOne Plus includes a shortcut that runs a command, so the terminal still opens
normally and OldieChat gets its own icon.

1. Long-press an empty spot on the home screen and choose **Widgets**.
2. Find **Term shortcut** (TermOne Plus) and drag it to the home screen.
3. In the dialog:
   - **Command**: `/system/bin/wsp`
   - **Arguments**: empty
   - **Shortcut label**: `OldieChat`
4. For the icon: long-press the shortcut, choose **Edit**, tap the icon and pick
   `/sdcard/OldieChat/oldiechat.png` from the gallery or a file manager.

## Shortcuts

One rule: **Volume up = move**, **Volume down = action**. Press and release the
volume button before the letter; pressed twice it stays locked and once more
releases it (both buttons work the same way). The same table appears on the
phone with Volume down + G.

| Keys | Action |
| --- | --- |
| Vol. up + W | go up in the conversation (selects messages) |
| Vol. up + S | go down in the conversation |
| Vol. up + A | previous chat |
| Vol. up + D | next chat |
| Enter | send message |
| Enter on a voice note | play; again: stop |
| Vol. down + A | **A**rchivados: show or hide archived chats |
| Vol. down + G | **G**uía: this table |
| Vol. down + S | back (or **S**alir: quit) |
| Back | same as Vol. down + S (with TermOne Plus set up as described above) |

- **Back**, step by step: while reviewing messages it returns to the chat list;
  in the archived list it returns to the regular list; in the guide it closes it.
  Only from the main list does it quit OldieChat, asking to confirm with Vol.
  down + S again.
- A and D always switch chats, also with a half-written message: the text stays
  as that chat's draft and shows up again when you come back.
- Enter always sends when there is text. Only with an empty input field, Enter
  on a selected voice note plays or stops it, and on any other message takes you
  back to typing.
- **The cursor always stays at the end of the text**: to fix something, delete.
  No key moves it back.
- Every other nchat shortcut is disabled.
- **Voice notes** are shown as `audio 00.33` (minutes.seconds). They are
  downloaded, converted and played in the background after 1–2 seconds, and stop
  when you quit. If one does not play, every step is logged in
  `/data/local/tmp/oldiechat/home/audio.log`.
- **Archived**: the status bar shows `[Archivados]` while that list is shown; it
  includes all your archived chats.
- **Taps**: tapping a name in the list opens that conversation, and two taps in a
  row on the input area open or close the keyboard.

## If you later use `adb shell` without root

`wsp` runs OldieChat as root, so new files are owned by root. To use it from
`adb shell` without root again:

```
su -c "chown -R shell:shell /data/local/tmp/oldiechat/home"
```

## Known limitations

- **Emoji** are shown in black and white (Noto Emoji). Those the font lacks, or
  that are drawn wider than their space in the terminal (some symbols such as ☀
  or ❤), are shown as a short emoticon (`<3`, `(sol)`) or as `[e]`. Messages are
  sent with the original emoji.
- **Text in other scripts** (Chinese, Japanese, Korean): Android 4.1 fonts draw
  it with a different width than the terminal, so it is shown as `?`.
- **Scrolling with the volume buttons**: in TermOne Plus a volume button set as a
  modifier cannot also send a key of its own, so scrolling uses Volume up + W/S.
- **Keyboard**: with "Send mouse events" on, TermOne Plus does not open the
  keyboard on a single tap; OldieChat works around it with the double tap on the
  input area.
- No system clipboard, no sending of voice notes, images or files, and no image
  viewer.
- Go 1.26 officially requires Linux kernel 3.2 or newer; it works on the Galaxy
  Fame's 3.0.15 kernel.
- Only tested on a Galaxy Fame. Other rooted Android 4.x ARMv7 phones should
  work; for good emoji rendering on another model, measure it again with
  `scripts/glyphs.sh` (see below).

## Emoji font

`install.sh` installs Noto Emoji (Google's monochrome version, SIL OFL 1.1
license, 850 KB) in `/system/fonts` and puts it in Android's fallback list before
`AndroidEmoji.ttf`, the original font that draws faces as robots. Android only
reads that list at boot, so the phone has to be rebooted once.

To undo it, from the computer:

```bash
adb shell
```

```
su
mount -o remount,rw /system
for f in /system/etc/fallback_fonts*.xml.orig; do cat $f > ${f%.orig}; rm $f; done
rm /system/fonts/NotoEmoji-OldieChat.ttf
mount -o remount,ro /system
reboot
```

After rebooting, measure again with `scripts/glyphs.sh` and run `install.sh`
again so `glyphs.txt` matches the phone's fonts.

## Compatibility

OldieChat exists to keep old phones working, so everything needed to build it is
pinned and stored:

- Exact versions of Alpine, Go, nchat, whatsmeow, libopus and the Java compiler in
  a single file, [`versions.env`](versions.env), with checksums.
- Go dependencies stored in the repository (`nchat/vendor/`, `engine/vendor/`)
  and patches in `nchat/patches/` (and `go/patches/` for Go).
- Every release also ships a package with the complete source code.
- `scripts/check-go-version.sh` warns when whatsmeow or nchat start requiring a
  newer Go, and `scripts/phone-test.sh` tests the phone (startup, DNS, HTTPS,
  audio) before each release.

What to do if Go stops working on an old kernel, whatsmeow requires a newer Go or
certificates expire: [MAINTAINING.md](MAINTAINING.md) (in Spanish).

## Building from source

```bash
sudo apt install -y docker.io qemu-user-static binfmt-support adb curl
```

```bash
sudo usermod -aG docker $USER
```

Log out and back in. Then:

```bash
./build.sh
```

The build runs emulated (Alpine armv7 on qemu) and takes a while. The output is
`out/oldiechat-terminal-<version>-armv7/` plus the `.tar.gz` and its `.sha256`
for Releases. `./build.sh shell` opens a shell in the container.

To generate `phone/config/glyphs.txt` by measuring the connected phone (about 9
minutes): the `GlyphProbe` program asks Android for each character's width and
draws it, the same way TermOne Plus does.

```bash
scripts/glyphs.sh
```

### How it works

- **nchat** is built with WhatsApp enabled and Telegram and Signal disabled,
  inside an Alpine armv7 (musl) container, with a patched Go (Go PR #69325,
  required for the whatsmeow part on musl), linked with `-static -no-pie`.
- **The engine** (`engine/`, Go) is independent of nchat and is the base of the
  future Android app: Opus→WAV conversion (`oldiechat-audio` uses it), DNS and
  certificates without root, time zone, and a messaging core on top of whatsmeow
  (`oldiechat-engine`). See [docs/APP_ARCHITECTURE.md](docs/APP_ARCHITECTURE.md)
  (in Spanish).
- **player.jar** (`player/`, Java) plays audio with Android's `MediaPlayer`,
  launched with `app_process`, without installing an app.
- **oldiechat.sh** sets up the environment: terminfo, time zone (Android uses
  its own tzdata format), `HOME` and the temp folder.

Patches applied to nchat (`nchat/patches/`):

| Patch | What it does |
| --- | --- |
| 0001 | Longer timeouts when linking and connecting (slow CPU). |
| 0002 | Pick a chat by tapping the list; double tap on the input area for the keyboard. |
| 0003 | Archived chats no longer reappear when their ID changes (LID ↔ phone number). |
| 0004 | Glyph filter (`glyphs.txt`) for old fonts and mismatched character widths. |
| 0005 | Use `/system/bin/sh` on Android to run external commands. |
| 0006 | Archived chats view (`toggle_archived`). |
| 0007 | Log every attempt to open an attachment and the command it runs. |
| 0008 | List all stored archived chats, even without recent messages. |
| 0009 | Simple keys, back, guide (`guide.txt`) and cursor always at the end. |
| 0010 | Short attachment labels: `audio mm.ss`, `imagen`, `video`, `sticker`, `documento pdf`. |
| 0011 | Terminal character widths (measured on the phone) instead of the C library's. |
| 0012 | whatsmeow version (date, `go.mod`, licenses); generated by `scripts/update-whatsmeow.sh`. |

Patches to the Go runtime, if ever needed, go in `go/patches/` (see
[MAINTAINING.md](MAINTAINING.md), in Spanish).

### Layout

```
build.sh            full build
Dockerfile.armv7    Alpine armv7 image
versions.env        exact versions and checksums
nchat/patches/      nchat patches
nchat/vendor/       nchat Go dependencies (go mod vendor)
go/patches/         own Go runtime patches (empty for now)
engine/             Go engine: audio, network, time zone, messaging
player/             Java: player and glyph measurement (app_process)
phone/              what gets installed on the phone: scripts, icon,
                    config/ (key, ui, color, glyphs, guide), fonts/ and
                    licenses/ (licenses the build does not provide)
scripts/            tests, glyphs, emoji font, icon, Go version, vendoring
tests/data/         test audio
docs/               project status and future app architecture
```

## Licenses

- OldieChat terminal's own code (scripts, patches, `engine/`, `player/`) is
  distributed under the [MIT](LICENSE) license.
- [nchat](https://github.com/d99kris/nchat) is distributed under the MIT license.
- [whatsmeow](https://github.com/tulir/whatsmeow) is distributed under the
  Mozilla Public License 2.0, unmodified (bundled in nchat's source).
- The [Noto Emoji](https://github.com/googlefonts/noto-emoji) font is distributed
  under the SIL Open Font License 1.1 (`licenses/OFL.txt` in the package).
- The **combined binary** in the package is distributed under the **GNU GPL v3**,
  like nchat's binaries without Signal.
- `licenses/` inside the package has the full licenses of everything in it:
  OldieChat, nchat, whatsmeow and its Go dependencies, libopus, Go, musl, the GCC
  runtime (with its exception), the static libraries (OpenSSL, zlib, ncurses,
  SQLite, libmagic and its compressors) and Noto Emoji. The time zone data
  (tzdata) is in the public domain.
- The corresponding source code is this repository plus the nchat commit set in
  `versions.env`, published in full with every release.

## Credits

- [nchat](https://github.com/d99kris/nchat), by Kristofer Berggren.
- [whatsmeow](https://github.com/tulir/whatsmeow), by Tulir Asokan.
- [TermOne Plus](https://gitlab.com/termapps/termoneplus), a continuation of
  Terminal Emulator for Android.
- [Opus](https://opus-codec.org/), by Xiph.Org.
