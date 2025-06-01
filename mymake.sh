#!/bin/env bash
make | awk -f parse-format-qb64-error.awk
