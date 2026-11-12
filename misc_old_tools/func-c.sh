#!/usr/bin/env bash
# The functions of the original C source (needs Universal Ctags): cfuncs.txt with name, line,
# file and declaration; cfuncs_uniq.txt with the names only, sorted. Run it from anywhere.
cd "$(dirname "$0")/.." || exit 1
ctags -x --c-types=f --format=1 origsrc/*.C > misc_old_tools/cfuncs.txt
awk '{print $1}' misc_old_tools/cfuncs.txt | sort -u > misc_old_tools/cfuncs_uniq.txt
