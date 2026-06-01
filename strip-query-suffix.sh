#!/usr/bin/env bash
#
# Recursively find files whose name contains a '?' and rename them by
# stripping the '?' and everything after it.
#
#   img/favicons/site.webmanifest?v=2  ->  img/favicons/site.webmanifest
#
# Usage:
#   ./strip-query-suffix.sh [DIR]      # rename under DIR (default: .)
#   DRY_RUN=1 ./strip-query-suffix.sh  # print what would happen, change nothing

set -euo pipefail

root="${1:-.}"

# Use -print0 / read -d '' so filenames with spaces, newlines, etc. are safe.
find "$root" -depth -type f -name '*\?*' -print0 |
while IFS= read -r -d '' path; do
    dir=$(dirname -- "$path")
    base=$(basename -- "$path")

    # Strip from the first '?' to the end of the basename.
    newbase=${base%%\?*}

    # Skip if stripping leaves an empty name (e.g. filename was "?foo").
    if [ -z "$newbase" ]; then
        printf 'SKIP (empty target): %s\n' "$path" >&2
        continue
    fi

    newpath="$dir/$newbase"

    if [ "$path" = "$newpath" ]; then
        continue
    fi

    if [ -e "$newpath" ]; then
        printf 'SKIP (target exists): %s -> %s\n' "$path" "$newpath" >&2
        continue
    fi

    if [ -n "${DRY_RUN:-}" ]; then
        printf 'DRY-RUN: %s -> %s\n' "$path" "$newpath"
    else
        mv -- "$path" "$newpath"
        printf 'RENAMED: %s -> %s\n' "$path" "$newpath"
    fi
done
