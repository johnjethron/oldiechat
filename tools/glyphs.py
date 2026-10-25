#!/usr/bin/env python3
#
# glyphs.py - genera glyphs.txt para el filtro de glifos de nchat (patches/0004).
#
# Se ejecuta dentro del contenedor Alpine armv7 (tools/glyphs.sh), para usar el
# wcwidth() real de musl, el mismo que usa nchat.
#
# Un carácter se deja tal cual solo si:
#   - alguna fuente del teléfono (system_fonts.xml + fallback_fonts.xml) lo tiene, y
#   - TermOne Plus en Android 4.x le da el mismo ancho que musl.
# Si no, se reemplaza por su forma NFKC (letras "decoradas", números en círculo,
# letras de ancho completo) o por un emoticono corto (que también reemplaza a las
# caras con forma de robot de Android 4.1); el resto lo resuelve nchat
# con los valores de las líneas E y O.
#
# Uso: glyphs.py <dir_fuentes> <dir_unicode_6.0> <salida>

import ctypes
import os
import re
import sys
import unicodedata

from fontTools.ttLib import TTFont

# Emoticonos cortos para emoji que la fuente de Android 4.1 no tiene
EMOTICONS = {
    0x1F60C: ":)", 0x1F60F: ":]", 0x1F613: "^^;", 0x1F616: ">_<", 0x1F617: ":*",
    0x1F619: ":*", 0x1F61A: ":*", 0x1F623: ">_<", 0x1F624: ">:(", 0x1F625: ":'(",
    0x1F628: "D:", 0x1F629: "D:", 0x1F62A: "-_-", 0x1F62B: "D:", 0x1F62C: ":S",
    0x1F630: "^^;", 0x1F633: "O_O", 0x1F634: "zZ", 0x1F635: "X_X", 0x1F637: ":#",
    0x1F600: ":D", 0x1F601: ":D", 0x1F602: "XD", 0x1F603: ":D", 0x1F604: ":D",
    0x1F605: "^^'", 0x1F606: "XD", 0x1F607: "O:)", 0x1F608: ">:)", 0x1F609: ";)",
    0x1F60A: ":)", 0x1F60B: ":P", 0x1F60D: "<3", 0x1F60E: "B)", 0x1F610: ":|",
    0x1F611: "-_-", 0x1F612: ":/", 0x1F614: ":(", 0x1F615: ":/", 0x1F618: ":*",
    0x1F61B: ":P", 0x1F61C: ";P", 0x1F61D: "XP", 0x1F61E: ":(", 0x1F620: ">:(",
    0x1F621: ">:(", 0x1F622: ":'(", 0x1F62D: ":'(", 0x1F62E: ":O", 0x1F631: "D:",
    0x1F632: ":O", 0x1F641: ":(", 0x1F642: ":)", 0x1F643: "(:", 0x1F644: "-_-",
    0x1F910: ":x", 0x1F911: "$_$", 0x1F912: ":S", 0x1F913: "8)", 0x1F914: ":-?",
    0x1F915: ":S", 0x1F917: "(hug)", 0x1F923: "XD", 0x1F924: ":P", 0x1F925: ":/",
    0x1F927: ":S", 0x1F928: ":/", 0x1F929: "*_*", 0x1F92A: ";P", 0x1F92D: ":x",
    0x1F92E: "X(", 0x1F92F: "O_O", 0x1F970: "<3", 0x1F971: "-o-", 0x1F972: ":')",
    0x1F973: "\\o/", 0x1F974: "%)", 0x1F975: ":S", 0x1F976: ":S", 0x1F97A: ":'(",
    0x1F44B: "o/", 0x1F44C: "ok", 0x1F44D: "(y)", 0x1F44E: "(n)", 0x1F44F: "(clap)",
    0x1F64C: "\\o/", 0x1F64F: "(pray)", 0x1F4AA: "(strong)", 0x1F91D: "(deal)",
    0x2764: "<3", 0x1F494: "</3", 0x1F495: "<3", 0x1F496: "<3", 0x1F497: "<3",
    0x1F499: "<3", 0x1F49A: "<3", 0x1F49B: "<3", 0x1F49C: "<3", 0x1F5A4: "<3",
    0x1F90D: "<3", 0x1F90E: "<3", 0x1F9E1: "<3",
    0x2705: "[v]", 0x2714: "v", 0x2716: "x", 0x274C: "[x]", 0x2757: "!", 0x2753: "?",
    0x26A0: "(!)", 0x26A1: "(!)", 0x2B50: "*", 0x1F31F: "*", 0x2728: "*",
    0x1F525: "(fire)", 0x1F389: "\\o/", 0x1F4AF: "100", 0x1F440: "(eyes)",
}

EMOJI_FALLBACK = "[e]"
OTHER_FALLBACK = "?"

ZERO_CATEGORIES = {"Cc", "Cf", "Mn", "Me"}


def load_unicode6(udir):
    cats = {}
    with open(os.path.join(udir, "UnicodeData.txt"), encoding="utf-8") as f:
        first = None
        for line in f:
            fields = line.split(";")
            cp, name, cat = int(fields[0], 16), fields[1], fields[2]
            if name.endswith(", First>"):
                first = cp
            elif name.endswith(", Last>"):
                for c in range(first, cp + 1):
                    cats[c] = cat
            else:
                cats[cp] = cat
    eaw = {}
    with open(os.path.join(udir, "EastAsianWidth.txt"), encoding="utf-8") as f:
        for line in f:
            line = line.split("#")[0].strip()
            if not line:
                continue
            rng, w = line.split(";")
            if ".." in rng:
                a, b = (int(x, 16) for x in rng.split(".."))
            else:
                a = b = int(rng, 16)
            for c in range(a, b + 1):
                eaw[c] = w.strip()
    return cats, eaw


def termone_width(cp, cats, eaw):
    # UnicodeTranscript.charWidth() de TermOne Plus en Android 4.1 (API 16,
    # ICU 4.8 = Unicode 6.0)
    if 31 < cp < 127:
        return 1
    if cats.get(cp, "Cn") in ZERO_CATEGORIES:
        return 0
    if 0x1160 <= cp <= 0x11FF or 0xD7B0 <= cp <= 0xD7FF:
        return 0
    if cp <= 0xFFFF:
        return 2 if eaw.get(cp, "N") in ("W", "F") else 1
    if (cp >> 16) & 0xF in (1, 2, 3):
        return 2
    return 1


def font_files(fontdir):
    names = []
    for xml in ("system_fonts.xml", "fallback_fonts.xml"):
        path = os.path.join(fontdir, xml)
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                names += re.findall(r"<file>([^<]+)</file>", f.read())
    if not names:
        names = [n for n in os.listdir(fontdir) if n.lower().endswith((".ttf", ".otf"))]
    seen = []
    for n in names:
        if n not in seen and os.path.exists(os.path.join(fontdir, n)):
            seen.append(n)
    return seen


def to_ranges(cps):
    ranges = []
    for cp in sorted(cps):
        if ranges and cp == ranges[-1][1] + 1:
            ranges[-1][1] = cp
        else:
            ranges.append([cp, cp])
    return ranges


def main():
    fontdir, udir, out = sys.argv[1:4]
    cats, eaw = load_unicode6(udir)

    covered = set()
    files = font_files(fontdir)
    for name in files:
        font = TTFont(os.path.join(fontdir, name), lazy=True, fontNumber=0)
        cmap = font.getBestCmap() or {}
        covered.update(cp for cp in cmap if cp >= 0xA0)

    libc = ctypes.CDLL(None)
    libc.wcwidth.argtypes = [ctypes.c_uint32]
    libc.wcwidth.restype = ctypes.c_int

    def musl_width(cp):
        return libc.wcwidth(cp)

    allowed = set()
    for cp in covered:
        if 0xD800 <= cp <= 0xDFFF:
            continue
        mw = musl_width(cp)
        if mw >= 0 and mw == termone_width(cp, cats, eaw):
            allowed.add(cp)

    # Las caras y gestos de AndroidEmoji (Android 4.1) son dibujos del robot de
    # Android: se prefiere el emoticono
    allowed -= set(EMOTICONS)

    def is_ok(s):
        return all(ord(ch) < 0xA0 or ord(ch) in allowed for ch in s)

    replacements = {}
    for cp in range(0xA0, 0x110000):
        if cp in allowed or 0xD800 <= cp <= 0xDFFF:
            continue
        if cp in EMOTICONS:
            replacements[cp] = EMOTICONS[cp]
            continue
        ch = chr(cp)
        if unicodedata.category(ch) == "Cn":
            continue
        nfkc = unicodedata.normalize("NFKC", ch)
        if nfkc != ch and nfkc.strip() and is_ok(nfkc) and len(nfkc) <= 4:
            replacements[cp] = nfkc

    with open(out, "w", encoding="utf-8") as f:
        f.write("# glyphs.txt - filtro de glifos para nchat (generado por tools/glyphs.py)\n")
        f.write("# fuentes: %s\n" % " ".join(files))
        f.write("E %s\n" % EMOJI_FALLBACK)
        f.write("O %s\n" % OTHER_FALLBACK)
        for a, b in to_ranges(allowed):
            f.write("A %X\n" % a if a == b else "A %X-%X\n" % (a, b))
        for cp in sorted(replacements):
            f.write("R %X %s\n" % (cp, replacements[cp]))

    print("fuentes: %d, permitidos: %d, reemplazos: %d" % (len(files), len(allowed), len(replacements)))


if __name__ == "__main__":
    main()
