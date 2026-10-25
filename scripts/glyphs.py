#!/usr/bin/env python3
#
# glyphs.py - genera glyphs.txt para el filtro de glifos de nchat (parche 0004).
#
# Entrada: la medición del teléfono hecha por GlyphProbe (scripts/glyphs.sh), una
# línea por carácter: "<hex> <ancho TermOne> <glifo 0/1> <avance>".
#
# Escribe los anchos de TermOne Plus (líneas W, que nchat usa en lugar de los de
# la biblioteca C, parche 0011) y deja un carácter tal cual solo si la fuente lo
# dibuja (no sale el cuadro de carácter faltante) y su ancho dibujado coincide con
# sus columnas (avance cerca de 1.00): TermOne dibuja la línea como texto corrido,
# y un glifo más ancho corre todo lo que sigue. Si no, se reemplaza por un
# emoticono corto o por su forma NFKC (letras "decoradas", números en círculo); el
# resto lo resuelve nchat con las líneas E/O.
#
# Uso: glyphs.py <probe.txt> <salida>

import sys
import unicodedata

# Emoticonos cortos para emoji que no se pueden dibujar bien (sin glifo o con un
# glifo de otro ancho). Con la fuente de emoji instalada, las caras se ven
# normales; sin ella, Android 4.1 las dibuja como robots.
EMOTICONS = {
    0x1F60C: ":)", 0x1F60F: ":]", 0x1F613: "^^;", 0x1F616: ">_<", 0x1F617: ":*",
    0x1F619: ":*", 0x1F61A: ":*", 0x1F623: ">_<", 0x1F624: ">:(", 0x1F625: ":'(",
    0x1F628: "D:", 0x1F629: "D:", 0x1F62A: "-_-", 0x1F62B: "D:", 0x1F62C: ":S",
    0x1F630: "^^;", 0x1F633: "O_O", 0x1F634: "zZ", 0x1F635: "X_X", 0x1F637: ":#",
    0x1F600: ":D", 0x1F601: ":D", 0x1F602: "XD", 0x1F603: ":D", 0x1F604: ":D",
    0x1F605: "^^'", 0x1F606: "XD", 0x1F607: "O:)", 0x1F608: ">:)", 0x1F609: ";)",
    0x1F60A: ":)", 0x1F60B: ":P", 0x1F60D: "<3", 0x1F60E: "B)", 0x1F610: ":|",
    0x1F611: "-_-", 0x1F612: ":/", 0x1F614: ":(", 0x1F615: ":/", 0x1F618: ":*",
    0x1F61B: ":P", 0x1F61C: ";P", 0x1F61D: "XP", 0x1F61E: ":(", 0x1F61F: ":(",
    0x1F620: ">:(", 0x1F621: ">:(", 0x1F622: ":'(", 0x1F626: "D:", 0x1F627: "D:",
    0x1F62D: ":'(", 0x1F62E: ":O", 0x1F62F: ":O", 0x1F631: "D:", 0x1F632: ":O",
    0x1F636: ":|", 0x1F641: ":(", 0x1F642: ":)", 0x1F643: "(:", 0x1F644: "-_-",
    0x1F910: ":x", 0x1F911: "$_$", 0x1F912: ":S", 0x1F913: "8)", 0x1F914: ":-?",
    0x1F915: ":S", 0x1F917: "(hug)", 0x1F920: ":)", 0x1F921: ":o)", 0x1F922: "X(",
    0x1F923: "XD", 0x1F924: ":P", 0x1F925: ":/", 0x1F927: ":S", 0x1F928: ":/",
    0x1F929: "*_*", 0x1F92A: ";P", 0x1F92B: ":x", 0x1F92D: ":x", 0x1F92E: "X(",
    0x1F92F: "O_O", 0x1F970: "<3", 0x1F971: "-o-", 0x1F972: ":')", 0x1F973: "\\o/",
    0x1F974: "%)", 0x1F975: ":S", 0x1F976: ":S", 0x1F978: "8)", 0x1F979: ":')",
    0x1F97A: ":'(", 0x1F9D0: "o_O", 0x1FAE0: ":S", 0x1FAE1: "o7", 0x1FAE2: ":O",
    0x1FAE3: ":x", 0x1FAE4: ":/", 0x1FAE5: ":|", 0x1FAE8: "@_@", 0x1FAE9: "-_-",
    0x263A: ":)", 0x2639: ":(",
    0x1F44B: "o/", 0x1F44C: "ok", 0x1F44D: "(y)", 0x1F44E: "(n)", 0x1F44F: "(clap)",
    0x1F64C: "\\o/", 0x1F64F: "(pray)", 0x1F4AA: "(strong)", 0x1F91D: "(deal)",
    0x261D: "^", 0x1FAF6: "<3",
    0x2764: "<3", 0x1F494: "</3", 0x1F495: "<3", 0x1F496: "<3", 0x1F497: "<3",
    0x1F499: "<3", 0x1F49A: "<3", 0x1F49B: "<3", 0x1F49C: "<3", 0x1F5A4: "<3",
    0x1F90D: "<3", 0x1F90E: "<3", 0x1F9E1: "<3", 0x1FA77: "<3",
    0x2705: "[v]", 0x2714: "v", 0x2716: "x", 0x274C: "[x]", 0x2757: "!", 0x2753: "?",
    0x26A0: "(!)", 0x26A1: "(!)", 0x2B50: "*", 0x1F31F: "*", 0x2728: "*",
    0x2600: "(sol)", 0x2601: "(nube)", 0x2615: "(cafe)", 0x2620: "(x_x)",
    0x1F525: "(fire)", 0x1F389: "\\o/", 0x1F4AF: "100", 0x1F440: "(eyes)",
}

EMOJI_FALLBACK = "[e]"
OTHER_FALLBACK = "?"

# avance aceptado (ancho dibujado / columnas): los emoji de Android 4.1 miden 1.07
ADVANCE_MIN, ADVANCE_MAX = 0.90, 1.10


def to_ranges(cps):
    ranges = []
    for cp in sorted(cps):
        if ranges and cp == ranges[-1][1] + 1:
            ranges[-1][1] = cp
        else:
            ranges.append([cp, cp])
    return ranges


def main():
    probe_path, out_path = sys.argv[1:3]

    allowed = set()
    widths = {}
    with open(probe_path) as f:
        for line in f:
            parts = line.split()
            if len(parts) != 4:
                continue
            cp, width, glyph, advance = int(parts[0], 16), int(parts[1]), int(parts[2]), float(parts[3])
            if width != 1:
                widths[cp] = width
            if width == 0:
                allowed.add(cp)  # combinantes y de formato: no se dibujan solos
            elif unicodedata.category(chr(cp)) == "Zs":
                allowed.add(cp)  # espacios: se dibujan en blanco
            elif glyph and ADVANCE_MIN <= advance <= ADVANCE_MAX:
                allowed.add(cp)

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

    with open(out_path, "w", encoding="utf-8") as f:
        f.write("# glyphs.txt - filtro de glifos para nchat (generado por scripts/glyphs.py)\n")
        f.write("E %s\n" % EMOJI_FALLBACK)
        f.write("O %s\n" % OTHER_FALLBACK)
        for w in (0, 2):
            for a, b in to_ranges(cp for cp, cw in widths.items() if cw == w):
                f.write("W %X %d\n" % (a, w) if a == b else "W %X-%X %d\n" % (a, b, w))
        for a, b in to_ranges(allowed):
            f.write("A %X\n" % a if a == b else "A %X-%X\n" % (a, b))
        for cp in sorted(replacements):
            f.write("R %X %s\n" % (cp, replacements[cp]))

    print("permitidos: %d, reemplazos: %d" % (len(allowed), len(replacements)))


if __name__ == "__main__":
    main()
