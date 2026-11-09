"""Formats all the sources with the QB64 IDE, also the include files that it can't check alone.

The QB64 IDE only formats the code it can parse. A .BM / .BI file opened on its own is not a
complete program, so the IDE stops at the first use of something defined in another file. So:

  merge  builds one complete program per build (the entry files WOLF3D.BAS, WOLF1.BAS, WOLFS14.BAS, SPEAR.BAS,
         SPEARDEMO.BAS, with every include inlined once, at its first active occurrence, like
         the include guards do), with marker comments around each file
  ide    opens each merged program in the QB64 IDE, jumps to the end, saves and exits
         (tools/ide_roundtrip.ps1)
  split  cuts the formatted programs back into the files (each one without the indentation of
         the place it was included at) and writes the files that changed

The IDE fully formats only the lines that are compiled; in the inactive $If blocks it only
re-indents, and flattens the loop and Case bodies. So split takes each line from a build in
which that line is compiled (lines no build compiles come from the first build). The IDE keeps
one line per line, and split checks that the builds give the same lines of each file.

python tools/ide_format.py          does all three; "merge" / "ide" / "split" do one step
"""
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
WORK = os.path.join(tempfile.gettempdir(), 'wolf3d-ide-format')
ENTRIES = ['WOLF3D.BAS', 'WOLF1.BAS', 'WOLFS14.BAS', 'SPEAR.BAS', 'SPEARDEMO.BAS']  # one per build
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

    def line_active(self, text):
        """Whether the line is compiled (a metacommand line counts with its enclosing block)"""
        st = text.strip()
        if re.match(r'\$(Else|ElseIf|End\s*If|EndIf)\b', st, re.I):
            return all(a for a, _ in self.stack[:-1])
        return self.active()

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


def merged_name(entry):
    return os.path.join(WORK, os.path.splitext(entry)[0] + '_ALL.BAS')


def merge():
    for entry in ENTRIES:
        meta = Meta()
        done = set()
        out = []
        act = []

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
                        act.append(True)
                        inline(inc, ind)
                        out.append(ind + MARK + 'END ' + inc)
                    else:
                        out.append(ind + MARK + 'INC ' + text.strip())
                    act.append(meta.active())
                    continue
                act.append(meta.line_active(text))
                meta.line(text)
                out.append(prefix + text if text.strip() else text)

        inline(entry, '')
        os.makedirs(WORK, exist_ok=True)
        merged = merged_name(entry)
        open(merged, 'w', encoding='latin-1', newline='').write('\r\n'.join(out) + '\r\n')
        open(merged + '.act', 'w').write(''.join('1' if a else '0' for a in act))
        print('merged %s: %d files, %d lines' % (entry, len(done), len(out)))


def split_one(entry):
    """{file: [(text, compiled)]} of one formatted build"""
    merged = merged_name(entry)
    lines = open(merged, encoding='latin-1', newline='').read().replace('\r\n', '\n')
    if lines.endswith('\n'):
        lines = lines[:-1]
    lines = lines.split('\n')
    act = [c == '1' for c in open(merged + '.act').read()]
    assert len(act) == len(lines), (entry, 'the IDE changed the number of lines', len(act), len(lines))
    files = {}
    stack = [[entry, 0, []]]  # name, base indentation, lines

    def indent(t):
        return len(t) - len(t.lstrip(' '))

    def unindent(t, base):
        return t[min(base, indent(t)):]

    for text, a in zip(lines, act):
        st = text.strip()
        if st.startswith(MARK):
            kind, rest = st[len(MARK):].split(' ', 1)
            cur = stack[-1]
            if kind == 'BEGIN':
                name, original = rest.split(' ', 1)
                ind = indent(text)
                cur[2].append((' ' * max(ind - cur[1], 0) + original, a))
                stack.append([name, ind, []])
            elif kind == 'END':
                name, base, body = stack.pop()
                assert name == rest, (name, rest)
                files[name] = body
            elif kind == 'INC':
                cur[2].append((' ' * max(indent(text) - cur[1], 0) + rest, a))
            continue
        cur = stack[-1]
        cur[2].append((unindent(text, cur[1]), a))
    assert len(stack) == 1
    files[entry] = stack[0][2]
    return files


def split():
    builds = [split_one(e) for e in ENTRIES]
    names = sorted({n for b in builds for n in b})
    changed = 0
    for name in names:
        versions = [b[name] for b in builds if name in b]
        assert len({len(v) for v in versions}) == 1, (name, 'the builds give different lines',
                                                      [len(v) for v in versions])
        body = []
        for k in range(len(versions[0])):
            # the line from a build that compiles it, else from the first build
            body.append(next((v[k][0] for v in versions if v[k][1]), versions[0][k][0]))
        path = os.path.join(ROOT, name)
        new = '\r\n'.join(body) + '\r\n'
        old = open(path, encoding='latin-1', newline='').read()
        if old.replace('\r\n', '\n') != new.replace('\r\n', '\n'):
            open(path, 'w', encoding='latin-1', newline='').write(new)
            changed += 1
            print('  formatted', name)
    print('%d of %d files changed' % (changed, len(names)))


def ide():
    ps = os.path.join(ROOT, 'tools', 'ide_roundtrip.ps1')
    for entry in ENTRIES:
        subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ps,
                        '-files', merged_name(entry), '-loadwait', '60'], check=True)


if __name__ == '__main__':
    step = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if step in ('merge', 'all'):
        merge()
    if step in ('ide', 'all'):
        ide()
    if step in ('split', 'all'):
        split()
