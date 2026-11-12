#!/usr/bin/env bash
# The Subs and Functions of the QB64 port, with their files: qb64subfuncs.txt. Run it from anywhere.
cd "$(dirname "$0")/.." || exit 1
grep -i -E "^ *Sub|^ *Func" basicsrc/*.B* > misc_old_tools/qb64subfuncs.txt
