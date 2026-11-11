"""Extracts the sign-on screen and the palette from an original game exe.

The original builds linked SIGNON.OBJ (the 320x200 sign-on screen, 64000 bytes, introscn) and
GAMEPAL.OBJ (the palette, 768 bytes of 6-bit VGA values, gamepal) into the exe, next to each
other: in the Spear of Destiny exes the screen is right before the palette, in the v1.0
shareware exe (WOLF3D-SHARE-ORIG.EXE) right after it. The source release only has the v1.4
Wolfenstein ones (basicsrc/OBJ/signon.bin, basicsrc/OBJ/gamepal.bin); the others are only in their exes. Those
exes are packed with LZEXE 0.91, so this
unpacks the load image, finds the palette (it starts with the standard colours 0, 1, 2:
0,0,0 0,0,42 0,42,0, all values below 64) and takes the 64000 bytes before or after it that
look like a picture: many pixels the same as their left neighbour, and not mostly zeros
(after the Spear palette comes zero-filled data).

python tools/extract_exe_data.py SPEAR-ORIG.EXE sod
python tools/extract_exe_data.py SPEAR-DEMO-ORIG.EXE sdm
python tools/extract_exe_data.py WOLF3D-SHARE-ORIG.EXE wl1
    writes basicsrc/OBJ/signon_<name>.bin and basicsrc/OBJ/gamepal_<name>.bin; then run tools/gen_signon.py
"""
import os
import struct
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))


def unlzexe(d):
    """The load image of an LZEXE 0.91 exe (the relocations are not needed here)"""
    pos = struct.unpack_from('<H', d, 8)[0] * 16  # the packed data starts after the header
    out = bytearray()
    # the flag words are read as in UNLZEXE: the next word right after the 16th bit is used
    bits = d[pos] | d[pos + 1] << 8
    pos += 2
    nbits = 16

    def getbit():
        nonlocal bits, nbits, pos
        b = bits & 1
        nbits -= 1
        if nbits == 0:
            bits = d[pos] | d[pos + 1] << 8
            pos += 2
            nbits = 16
        else:
            bits >>= 1
        return b

    def getbyte():
        nonlocal pos
        pos += 1
        return d[pos - 1]

    while True:
        if getbit():
            out.append(getbyte())  # a literal byte
            continue
        if getbit() == 0:
            length = ((getbit() << 1) | getbit()) + 2
            span = getbyte() - 0x100
        else:
            lo = getbyte()
            hi = getbyte()
            span = (lo | ((hi & 0xF8) << 5) | 0xE000) - 0x10000
            length = hi & 7
            if length == 0:
                length = getbyte()
                if length == 0:
                    break  # end of the data
                if length == 1:
                    continue  # segment change
                length += 1
            else:
                length += 2
        for _ in range(length):
            out.append(out[len(out) + span])
    return bytes(out)


def find_palette(img):
    found = [k for k in range(64000, len(img) - 768)
             if img[k:k + 9] == bytes([0, 0, 0, 0, 0, 42, 0, 42, 0]) and max(img[k:k + 768]) < 64]
    if len(found) != 1:
        raise SystemExit('expected one palette, found %d' % len(found))
    return found[0]


def picture_score(block):
    """How much a 64000-byte block looks like a 320x200 screen, 0 if it does not"""
    if len(block) < 64000 or block.count(0) > len(block) // 2:
        return 0
    return sum(1 for i in range(1, 64000) if i % 320 and block[i] == block[i - 1]) / 64000


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    exe, name = sys.argv[1], sys.argv[2].lower()
    data = open(exe, 'rb').read()
    if data[:2] != b'MZ' or b'\xff\xff\xba' not in data[0x1c:0x24]:
        raise SystemExit('%s does not look like an LZEXE 0.91 exe' % exe)
    img = unlzexe(data)
    p = find_palette(img)
    pal = img[p:p + 768]
    sides = {'before': p - 64000, 'after': p + 768}
    side = max(sides, key=lambda k: picture_score(img[sides[k]:sides[k] + 64000]))
    if picture_score(img[sides[side]:sides[side] + 64000]) < 0.3:
        raise SystemExit('no sign-on screen next to the palette')
    signon = img[sides[side]:sides[side] + 64000]
    for fname, block in (('signon_%s.bin' % name, signon), ('gamepal_%s.bin' % name, pal)):
        open(os.path.join(ROOT, 'basicsrc', 'OBJ', fname), 'wb').write(block)
        print('wrote basicsrc/OBJ/%s (%d bytes)' % (fname, len(block)))
    print('(%s: %d bytes unpacked, the palette at %d, the screen %s it at %d)' % (exe, len(img), p, side, sides[side]))


if __name__ == '__main__':
    main()
