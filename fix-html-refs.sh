#!/usr/bin/env bash
#
# Rewrite asset references in HTML files: strip the URL-encoded query
# suffix ('%3F' + everything after it, up to the URL delimiter).
#
#   img/new-logo-day.svg%3F1DFDE359...725A  ->  img/new-logo-day.svg
#   highlightjs/styles/x.css%3FHASH.css     ->  highlightjs/styles/x.css
#
# The regex requires at least ONE character after %3F, so a bare trailing
# "%3F" (e.g. the external link .../clojure.core/some%3F, where %3F is a
# real encoded '?') is left untouched.
#
# Delimiters that end a URL: quotes, parens, angle brackets, whitespace, comma.
#
# Usage:
#   ./fix-html-refs.sh [DIR]            # edit in place (default dir: .)
#   DRY_RUN=1 ./fix-html-refs.sh        # show what would change, edit nothing

set -euo pipefail

root="${1:-.}"

# Perl one-liner: %3F (case-insensitive) + run of non-delimiter chars -> removed.
pattern='s/%3[Ff][^"'"'"'()<>\s,]+//g'

if [ -n "${DRY_RUN:-}" ]; then
    # Show only files (and lines) that would change, without writing.
    find "$root" -type f -name '*.html' -print0 |
    while IFS= read -r -d '' f; do
        if perl -ne 'exit 1 if /%3[Ff][^"'"'"'()<>\s,]+/' "$f"; then :; else
            printf '=== %s ===\n' "$f"
            perl -ne 'print if /%3[Ff][^"'"'"'()<>\s,]+/' "$f" | head -3
        fi
    done
else
    find "$root" -type f -name '*.html' -print0 |
        xargs -0 perl -i -pe "$pattern"
    echo "Done. Remaining %3F occurrences (should only be trailing ones like some%3F):"
    grep -rhoE '[^"'"'"'()<> ,]*%3[Ff][^"'"'"'()<> ,]*' --include='*.html' "$root" | sort -u
fi
