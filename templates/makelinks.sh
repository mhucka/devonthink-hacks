#!/usr/bin/env bash
# Summary: create hard links to these template files in an iCloud folder.
#
# Copyright 2024 Michael Hucka.
# License: MIT license – see file "LICENSE" in the project website.
# Website: https://github.com/mhucka/devonthink-hacks

set -e

thisdir="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
clouddir="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/DEVONthink templates"

# Dealing with spaces in file names is such a PITA.
IFS=$'\n'
for path in `find -E *.noindex -maxdepth 2 -iregex '.*\.(md|ooutline|numbers)'`; do
    filename=$(basename "$path")
    ln "$thisdir/$path" "$clouddir/"
done
