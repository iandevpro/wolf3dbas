"""Generates WL_SPR.BI, the sprite numbers (the sprite enum of origsrc/WL_DEF.H).

The enum has #ifdef SPEAR / #ifndef SPEAR parts, so the numbers after the first of them differ
between the Wolfenstein and the Spear builds: WL_SPR.BI has one numbered list per game.

The Wolfenstein list also serves the v1.0 shareware data (APOGEE_1_0): VSWAP.WL1 has the same
sprites in the same order, but without SPR_DEATHCAM and without the 47 sprites before SPR_BJ_W1
(Giftmacher, rockets, Gretel, Fat Face; the death cam came with v1.1). So with APOGEE_1_0 the
sprites from SPR_STAT_0 on are one lower, and those from SPR_BJ_W1 on 48 lower.

python tools/gen_sprites.py
"""
import os
import re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))


def sprites(spear):
    text = open(os.path.join(ROOT, 'origsrc', 'WL_DEF.H'), encoding='latin-1').read().replace('\r', '')
    i = text.index('SPR_DEMO')
    body = text[i:text.index('};', i)]
    names = []
    stack = [True]
    for line in body.split('\n'):
        s = line.strip()
        m = re.match(r'#(ifdef|ifndef)\s+(\w+)', s)
        if m:
            assert m.group(2) == 'SPEAR', s
            stack.append(stack[-1] and (spear if m.group(1) == 'ifdef' else not spear))
            continue
        if s.startswith('#else'):
            top = stack.pop()
            stack.append(stack[-1] and not top)
            continue
        if s.startswith('#endif'):
            stack.pop()
            continue
        if stack[-1]:
            # (MACHINEGUNATK3 has no SPR_ in the C code)
            names += re.findall(r'\b([A-Z][A-Z0-9_]*)\b', re.sub(r'//.*', '', s))
    return names


def main():
    spear = sprites(True)
    wolf = sprites(False)
    bj = wolf.index('SPR_BJ_W1')
    out = ["' WL_SPR.BI - the sprite numbers (the sprite enum of WL_DEF.H)",
           "' Generated from origsrc/WL_DEF.H by tools/gen_sprites.py, do not edit",
           "$If INCLUDE_WL_SPR_BI = UNDEFINED Then",
           "    $Let INCLUDE_WL_SPR_BI = 1",
           "",
           "    $If SPEAR = DEFINED Then",
           "        ' Spear of Destiny (%d sprites, the VSWAP.SOD / VSWAP.SDM files have 421)" % len(spear)]
    out += ["        Const %s = %d" % (n, v) for v, n in enumerate(spear)]
    out += ["    $Else",
            "        ' Wolfenstein 3-D (%d sprites, VSWAP.WL6 has 436)" % len(wolf),
            "        ' The v1.0 shareware data (VSWAP.WL1) has the same sprites in the same order,",
            "        ' but without SPR_DEATHCAM and without the 47 sprites before SPR_BJ_W1 (Giftmacher,",
            "        ' rockets, Gretel, Fat Face). The other episodes' sprites are empty pages there.",
            "        ' So with APOGEE_1_0 the sprites from SPR_STAT_0 on are one lower, those from",
            "        ' SPR_BJ_W1 on 48 lower; SPR_DEATHCAM is not there (the death cam came with v1.1)",
            "        $If APOGEE_1_0 = DEFINED Then",
            "            Const SPRV10SHIFT1 = 1",
            "            Const SPRV10SHIFT2 = 48",
            "        $Else",
            "            Const SPRV10SHIFT1 = 0",
            "            Const SPRV10SHIFT2 = 0",
            "        $End If"]
    for v, n in enumerate(wolf):
        if v >= bj:
            out.append("        Const %s = %d - SPRV10SHIFT2" % (n, v))
        elif v >= 2:
            out.append("        Const %s = %d - SPRV10SHIFT1" % (n, v))
        else:
            out.append("        Const %s = %d" % (n, v))
    out += ["    $End If", "", "$End If"]
    open(os.path.join(ROOT, 'basicsrc', 'WL_SPR.BI'), 'w', encoding='latin-1', newline='').write('\r\n'.join(out) + '\r\n')
    print('WL_SPR.BI: %d Spear sprites, %d Wolfenstein sprites' % (len(spear), len(wolf)))


if __name__ == '__main__':
    main()
