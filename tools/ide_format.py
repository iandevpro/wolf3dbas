"""Formats all the sources with the QB64 IDE, also the include files that it can't check alone.

The QB64 IDE only formats the code it can parse. A .BM / .BI file opened on its own is not a
complete program, so the IDE stops at the first use of something defined in another file. So:

  merge  builds one complete program (WOLF3D.BAS with every include inlined once, at its first
         active occurrence, like the include guards do), with marker comments around each file
  ide    opens the merged program in the QB64 IDE, jumps to the end, saves and exits
         (tools/ide_roundtrip.ps1)
  split  cuts the formatted program back into the files (each one without the indentation of
         the place it was included at) and writes the files that changed

python tools/ide_format.py          does all three; "merge" / "split" do one step
"""
import os
import re
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
WORK = os.path.join(os.environ.get('TEMP', ROOT), 'wolf3d-ide-format')
MERGED = os.path.join(WORK, 'WOLF3D_ALL.BAS')
MAIN = 'WOLF3D.BAS'
MARK = "'@@IDEFMT "

INCLUDE_RE = re.compile(r"^\s*'\$INCLUDE\s*:\s*'([^']+)'", re.I)


def read_lines(name):
    s = open(os.path.join(ROOT, name), encoding='latin-1', newline='').read().replace('\r\n', '\n')
    if s.endswith('\n'):
        s = s[:-1]  # (blank lines at the end are kept)
    return s.split('\n')


class Meta:
    """The $Let / $If state, to know which lines QB64 compiles"""

    def __init__(self):
        self.vars = {}
        self.stack = []  # (active, any_branch_taken)

    def active(self):
        return all(a for a, _ in self.stack)

    def cond(self, expr):
        m = re.match(r'\s*(\w+)\s*=\s*(\w+)\s*$', expr)
        if not m:
            raise ValueError('unknown $If condition: ' + expr)
        name, val = m.group(1).upper(), m.group(2).upper()
        if val == 'DEFINED':
            return name in self.vars
        if val == 'UNDEFINED':
            return name not in self.vars
        return self.vars.get(name) == val

    def line(self, text):
        st = text.strip()
        m = re.match(r'\$Let\s+(\w+)\s*=\s*(\w+)', st, re.I)
        if m:
            if self.active():
                self.vars[m.group(1).upper()] = m.group(2).upper()
            return
        m = re.match(r'\$If\s+(.*?)\s+Then\s*$', st, re.I)
        if m:
            c = self.active() and self.cond(m.group(1))
            self.stack.append((c, c))
            return
        m = re.match(r'\$ElseIf\s+(.*?)\s+Then\s*$', st, re.I)
        if m:
            a, taken = self.stack.pop()
            outer = self.active()
            c = outer and not taken and self.cond(m.group(1))
            self.stack.append((c, taken or c))
            return
        if re.match(r'\$Else\s*$', st, re.I):
            a, taken = self.stack.pop()
            c = self.active() and not taken
            self.stack.append((c, True))
            return
        if re.match(r'\$End\s*If\s*$', st, re.I) or re.match(r'\$EndIf\s*$', st, re.I):
            self.stack.pop()


def merge():
    meta = Meta()
    done = set()
    out = []

    # an inlined file is indented like the include line, as the IDE will indent it
    def inline(name, prefix):
        done.add(name.upper())
        for text in read_lines(name):
            m = INCLUDE_RE.match(text)
            ind = prefix + text[:len(text) - len(text.lstrip(' '))]
            if m:
                inc = m.group(1)
                if meta.active() and inc.upper() not in done:
                    out.append(ind + MARK + 'BEGIN ' + inc + ' ' + text.strip())
                    inline(inc, ind)
                    out.append(ind + MARK + 'END ' + inc)
                else:
                    out.append(ind + MARK + 'INC ' + text.strip())
                continue
            meta.line(text)
            out.append(prefix + text if text.strip() else text)

    inline(MAIN, '')
    os.makedirs(WORK, exist_ok=True)
    open(MERGED, 'w', encoding='latin-1', newline='').write('\r\n'.join(out) + '\r\n')
    print('merged %d files, %d lines: %s' % (len(done), len(out), MERGED))


def split():
    lines = open(MERGED, encoding='latin-1', newline='').read().replace('\r\n', '\n')
    if lines.endswith('\n'):
        lines = lines[:-1]
    lines = lines.split('\n')
    files = {}
    stack = [[MAIN, 0, []]]  # name, base indentation, lines

    def indent(t):
        return len(t) - len(t.lstrip(' '))

    def unindent(t, base):
        return t[min(base, indent(t)):]

    for text in lines:
        st = text.strip()
        if st.startswith(MARK):
            kind, rest = st[len(MARK):].split(' ', 1)
            cur = stack[-1]
            if kind == 'BEGIN':
                name, original = rest.split(' ', 1)
                ind = indent(text)
                cur[2].append(' ' * max(ind - cur[1], 0) + original)
                stack.append([name, ind, []])
            elif kind == 'END':
                name, base, body = stack.pop()
                assert name == rest, (name, rest)
                files[name] = body
            elif kind == 'INC':
                cur[2].append(' ' * max(indent(text) - cur[1], 0) + rest)
            continue
        cur = stack[-1]
        cur[2].append(unindent(text, cur[1]))
    assert len(stack) == 1
    files[MAIN] = stack[0][2]

    changed = 0
    for name, body in sorted(files.items()):
        path = os.path.join(ROOT, name)
        new = '\r\n'.join(body) + '\r\n'
        old = open(path, encoding='latin-1', newline='').read()
        if old.replace('\r\n', '\n') != new.replace('\r\n', '\n'):
            open(path, 'w', encoding='latin-1', newline='').write(new)
            changed += 1
            print('  formatted', name)
    print('%d of %d files changed' % (changed, len(files)))


def ide():
    ps = os.path.join(ROOT, 'tools', 'ide_roundtrip.ps1')
    subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ps,
                    '-files', MERGED, '-loadwait', '60'], check=True)


if __name__ == '__main__':
    step = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if step in ('merge', 'all'):
        merge()
    if step in ('ide', 'all'):
        ide()
    if step in ('split', 'all'):
        split()
