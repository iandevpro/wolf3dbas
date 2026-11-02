"""Generates the data headers of each game version from the C headers in origsrc/:

  GFXV_*.BI   graphics chunk numbers, lumps and counts  (GFXV_WL6.H, GFXV_SOD.H, GFXV_SDM.H, GFXV_WL1.H)
  AUDIO*.BI   sound and music numbers                     (AUDIOWL6.H, AUDIOSOD.H, AUDIOSDM.H)
  MAPS*.BI    map names                                    (MAPSWL6.H, MAPSSOD.H, MAPSSDM.H)

Each #define with a number and each enum member becomes a Const, in the order of the header,
with the header's section comments. ID_HEADS.BI includes the files of the version being built.

The v1.0 shareware data (*.WL1, APOGEE_1_0) does not fit its headers, so its two files get
fixes (see V10_*): GFXV_WL1.H fits the pictures but not the chunks after them, and the audio
is the WL6 list with fewer sounds (AUDIOWL1.H, April 1992, is older than that data).

python tools/gen_headers.py   (writes the .BI files in the source directory)
"""
import os
import re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SRC = os.path.join(ROOT, 'origsrc')


def parse(hname):
    """The header as a list of ('comment', text) / ('const', name, value) / ('blank',)"""
    text = open(os.path.join(SRC, hname), encoding='latin-1').read().replace('\r', '')
    items = []
    created = None
    in_enum = False
    value = 0
    for line in text.split('\n'):
        s = line.strip()
        m = re.match(r'//\s*(Created .*|IGRAB-ed .*)$', s)
        if m:
            created = m.group(1)
            continue
        if s.startswith('typedef enum'):
            in_enum, value = True, 0
            continue
        if in_enum and s.startswith('}'):
            in_enum = False
            continue
        m = re.match(r'//\s*(.*?)\s*$', s)
        if m:
            c = m.group(1)
            # section titles only, not the boxes of slashes or the closing thanks
            if c and not re.match(r'^/*$', c) and not re.match(r'(Thank|Thanks|MUSE Header|Graphics \.H|TED5)', c):
                items.append(('comment', c))
            continue
        if in_enum:
            for m in re.finditer(r'(\w+)\s*(?:=\s*(\d+))?\s*,?', re.sub(r'//.*', '', s)):
                name, val = m.group(1), m.group(2)
                if val is not None:
                    value = int(val)
                items.append(('const', name, value))
                value += 1
            continue
        m = re.match(r'#define\s+(\w+)\s+(\d+)\s*$', s)
        if m:
            items.append(('const', m.group(1), int(m.group(2))))
            continue
        if not s and items and items[-1] != ('blank',):
            items.append(('blank',))
    return created, items


def write(bname, hname, created, items, notes=()):
    guard = 'INCLUDE_' + bname.replace('.', '_').upper()
    out = ["' %s - generated from origsrc/%s (%s) by tools/gen_headers.py" % (bname, hname, created or '?')]
    out += ["' " + n if n else "'" for n in notes]
    out += ['', '$If %s = UNDEFINED Then' % guard, '    $Let %s = 1' % guard, '']
    prev_blank = True
    for it in items:
        if it[0] == 'blank':
            if not prev_blank:
                out.append('')
            prev_blank = True
            continue
        if it[0] == 'comment':
            if not prev_blank:
                out.append('')
            out.append("    ' " + it[1])
        else:
            out.append('    Const %s = %d' % (it[1], it[2]))
        prev_blank = False
    while out[-1] == '':
        out.pop()
    out += ['', '$End If']
    path = os.path.join(ROOT, bname)
    new = '\r\n'.join(out) + '\r\n'
    old = open(path, encoding='latin-1', newline='').read() if os.path.exists(path) else None
    if old is None or old.replace('\r\n', '\n') != new.replace('\r\n', '\n'):
        open(path, 'w', encoding='latin-1', newline='').write(new)
        print('wrote', bname)
    return {it[1]: it[2] for it in items if it[0] == 'const'}


def replace_consts(items, values, drop=(), append=()):
    out = []
    for it in items:
        if it[0] == 'const' and it[1] in drop:
            continue
        if it[0] == 'const' and it[1] in values:
            it = ('const', it[1], values[it[1]])
        out.append(it)
    return out + list(append)


# --- v1.0 shareware fixes ---

# VGAHEAD.WL1 has 148 chunks: the pictures 3-138 as in GFXV_WL1.H, then the 8x8 tiles, the
# order and error screens, the help text, one end text and four demos (no 16x16 tiles)
V10_GFX_EXTERNS = [('ORDERSCREEN', 140), ('ERRORSCREEN', 141), ('T_HELPART', 142), ('T_ENDART1', 143),
                   ('T_DEMO0', 144), ('T_DEMO1', 145), ('T_DEMO2', 146), ('T_DEMO3', 147), ('ENUMEND', 148)]
V10_GFX_COUNTS = {'NUMCHUNKS': 148, 'NUMTILE16': 0, 'NUMTILE16M': 0, 'NUMEXTERNS': 8,
                  'STARTTILE8M': 140, 'STARTTILE16': 140, 'STARTTILE16M': 140, 'STARTTILE32': 140,
                  'STARTTILE32M': 140, 'STARTEXTERNS': 140}
V10_GFX_NOTES = [
    "The v1.0 shareware data (VGAGRAPH.WL1, May 1992). The pictures (3-138) are as in",
    "GFXV_WL1.H. The rest of that header does not fit the data: VGAHEAD.WL1 has 148 chunks,",
    "with no 16x16 tiles, and the externs after the 8x8 tiles are the order and error screens,",
    "the help text, one end text and four demos (in the v1.0 format, see PollControls).",
    "Not in v1.0: C_TIMECODEPIC, C_LEVELPIC, C_NAMEPIC, C_SCOREPIC, C_JOY1PIC, C_JOY2PIC,",
    "L_APOSTROPHEPIC and T_ENDART2-6 (the code that uses them checks APOGEE_1_0)"]

# AUDIOT.WL1 has the first 73 sounds of the WL6 list with the same numbers, and the same music
V10_AUDIO_COUNTS = {'NUMSOUNDS': 73, 'NUMSNDCHUNKS': 246, 'STARTADLIBSOUNDS': 73,
                    'STARTDIGISOUNDS': 146, 'STARTMUSIC': 219}
V10_AUDIO_NOTES = [
    "The v1.0 shareware data (AUDIOT.WL1) has the first 73 sounds of the WL6 list, with the",
    "same numbers (the sounds 73-86 were added later), and the same music slots. AUDIOWL1.H",
    "(April 1992, 69 sounds) is older than that data and does not fit it. The names of the",
    "later sounds stay, SD_PlaySound ignores the sounds from NUMSOUNDS on"]


def main():
    for ver in ('WL6', 'SOD', 'SDM'):
        for kind in ('GFXV_', 'AUDIO', 'MAPS'):
            h = kind + ver + '.H'
            created, items = parse(h)
            write(kind + ver + '.BI', h, created, items)

    created, items = parse('GFXV_WL1.H')
    items = replace_consts(items, V10_GFX_COUNTS, drop={'ORDERSCREEN', 'ERRORSCREEN', 'ENUMEND'},
                           append=[('blank',), ('comment', 'externs (chunk numbers in VGAHEAD.WL1)')] +
                           [('const', n, v) for n, v in V10_GFX_EXTERNS])
    # the externs follow the pictures: move them before the lumps
    i = items.index(('comment', 'externs (chunk numbers in VGAHEAD.WL1)')) - 1
    tail = items[i:]
    j = next(k for k, it in enumerate(items) if it == ('comment', 'Data LUMPs'))
    items = items[:j] + tail + [('blank',)] + items[j:i]
    write('GFXV_WL1.BI', 'GFXV_WL1.H', created, items, V10_GFX_NOTES)

    created, items = parse('AUDIOWL6.H')
    write('AUDIOWL1.BI', 'AUDIOWL6.H', created, replace_consts(items, V10_AUDIO_COUNTS), V10_AUDIO_NOTES)


if __name__ == '__main__':
    main()
