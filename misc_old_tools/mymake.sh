#!/usr/bin/env bash
# make (all five builds, see ../Makefile), with the QB64 errors as "LINE n: error: code" for
# the editor (see parse-format-qb64-error.awk). Run it from anywhere.
cd "$(dirname "$0")/.." || exit 1
make | awk -f misc_old_tools/parse-format-qb64-error.awk
