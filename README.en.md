# OldieChat terminal

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
- Show the emoji that the Android 4.x font can draw and replace the rest with
  short emoticons.

For now it does not send voice notes, images or files, and does not show images.

Tested on a **Samsung Galaxy Fame GT-S6810L** (Android 4.1.2, kernel 3.0.101,
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
   - installs the configuration (`key.conf`, `ui.conf`, `glyphs.txt`), backing up
     any existing one as `.bak`;
   - creates `/system/etc/resolv.conf` with public DNS (`1.1.1.1` and `8.8.8.8`);
   - installs current root certificates in
     `/system/etc/ssl/certs/ca-certificates.crt`;
   - keeps an `.orig` copy of those two files if they already existed;
   - creates the `/system/bin/wsp` command;
   - copies the icon to `/sdcard/OldieChat/oldiechat.png`.

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

Volume up = **Fn**, Volume down = **Ctrl**. Press and release a modifier before
the key; pressed twice it stays locked until you press it again.

| Keys | Action |
| --- | --- |
| Enter | send message |
| Fn+0 | line break |
| Fn+1 / Fn+2 | previous / next conversation |
| Fn+3 | next unread conversation |
| Fn+4 | find conversation by name |
| Fn+5 | show or hide the list |
| Fn+6 | insert emoji |
| Fn+7 | react to the selected message |
| Fn+8 | on-screen help |
| Fn+9 | switch between regular and **archived** chats |
| Fn+W / Fn+S | up / down one message (selects the message) |
| Fn+P / Fn+N | up / down one page |
| Ctrl+9 | play the selected voice note (again: stop) |
| Ctrl+0 | stop playback |
| Ctrl+Q | quit |

All other nchat shortcuts remain available with Ctrl (see
[nchat](https://github.com/d99kris/nchat#usage)).

**Taps**: tapping a name in the list opens that conversation. Two taps in a row
(within 3 seconds) on the input area open or close the keyboard. The Back button
also closes the keyboard.

**Archived**: Fn+9 switches the list to show only archived chats and the status
bar shows `[Archivados]`. Fn+9 again goes back to the regular list.

**Voice notes**: select the voice message with Fn+W/Fn+S and press Ctrl+9. It is
downloaded, converted and played in the background after 1–2 seconds. Ctrl+0
stops it; it also stops when you quit.

## If you later use `adb shell` without root

`wsp` runs OldieChat as root, so new files are owned by root. To use it from
`adb shell` without root again:

```
su -c "chown -R shell:shell /data/local/tmp/oldiechat/home"
```

## Known limitations

- **Emoji**: the Android 4.1 font only has 2012-era emoji, in black and white.
  Newer ones are shown as `[e]` or as a short emoticon. Faces are always shown as
  emoticons (`:)`, `XD`, `<3`), because that font draws them as Android robots.
  Messages are sent with the original emoji.
- **Scrolling with the volume buttons**: in TermOne Plus a volume button set as a
  modifier cannot also send a key of its own, so scrolling uses Fn+W/S and
  Fn+P/N.
- **Keyboard**: with "Send mouse events" on, TermOne Plus does not open the
  keyboard on a single tap; OldieChat works around it with the double tap on the
  input area.
- No system clipboard, no sending of voice notes, images or files, and no image
  viewer.
- Go 1.26 officially requires Linux kernel 3.2 or newer; it works on the Galaxy
  Fame's 3.0.101 kernel.
- Only tested on a Galaxy Fame. Other rooted Android 4.x ARMv7 phones should
  work; for good emoji rendering on another model, generate `glyphs.txt` from its
  fonts (see below).

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

To generate `config/glyphs.txt` from the fonts of another connected phone:

```bash
tools/glyphs.sh
```

### How it works

- **nchat** is built with WhatsApp enabled and Telegram and Signal disabled,
  inside an Alpine armv7 (musl) container, with a patched Go (Go PR #69325,
  required for the whatsmeow part on musl), linked with `-static -no-pie`.
- **oldiechat-audio** (`audio/`, Go + libopus) converts Ogg Opus voice notes to
  WAV. The `oggopus` package is meant to be reused by the future app's engine.
- **player.jar** (`player/`, Java) plays audio with Android's `MediaPlayer`,
  launched with `app_process`, without installing an app.
- **oldiechat.sh** sets up the environment: terminfo, time zone (Android uses
  its own tzdata format), `HOME` and the temp folder.

Patches applied to nchat (`patches/`):

| Patch | What it does |
| --- | --- |
| 0001 | Longer timeouts when linking and connecting (slow CPU). |
| 0002 | Pick a chat by tapping the list; double tap on the input area for the keyboard. |
| 0003 | Archived chats no longer reappear when their ID changes (LID ↔ phone number). |
| 0004 | Glyph filter (`glyphs.txt`) for old fonts and mismatched character widths. |
| 0005 | Use `/system/bin/sh` on Android to run external commands. |
| 0006 | Archived chats view (`toggle_archived`). |
| 0007 | `stop` key and `attachment_stop_command` option. |

### Layout

```
build.sh            full build
Dockerfile.armv7    Alpine armv7 image
patches/            nchat patches
audio/              Opus -> WAV converter (Go)
player/             player (Java, app_process)
files/              scripts and icon shipped in the package
config/             key.conf, ui.conf, glyphs.txt
tools/              glyphs.txt and icon generators
```

## Licenses

- OldieChat terminal's own code (scripts, patches, `audio/`, `player/`, tools) is
  distributed under the [MIT](LICENSE) license.
- [nchat](https://github.com/d99kris/nchat) is distributed under the MIT license.
- [whatsmeow](https://github.com/tulir/whatsmeow) is distributed under the
  Mozilla Public License 2.0, unmodified (bundled in nchat's source).
- The **combined binary** in the package is distributed under the **GNU GPL v3**,
  like nchat's binaries without Signal. The full licenses of nchat, whatsmeow,
  libopus and the static libraries are in `licenses/` inside the package. The
  corresponding source code is this repository plus the nchat commit set in
  `build.sh`.

## Credits

- [nchat](https://github.com/d99kris/nchat), by Kristofer Berggren.
- [whatsmeow](https://github.com/tulir/whatsmeow), by Tulir Asokan.
- [TermOne Plus](https://gitlab.com/termapps/termoneplus), a continuation of
  Terminal Emulator for Android.
- [Opus](https://opus-codec.org/), by Xiph.Org.
