#!/usr/bin/env bash
# Lists the unused and repeated imports of Java files, one `path:line: import …;` per line, for the
# unused-imports skill. With no argument: every .java file changed and not yet committed in the current
# repository and its submodules (modified, staged or untracked). With arguments: those files, or
# `--since <ref>` for the files the current repository changed since that commit.
#
# An import counts as used when its simple name (a static import: its member) appears as a word anywhere
# else in the file, comments and javadoc included: it may keep an unused import a comment names, never drop
# a used one. Wildcard imports are left alone. Prints nothing and exits 0 when all are used; exits 1 otherwise.
set -uo pipefail

root=$(git rev-parse --show-toplevel)

prefix() { # $1: a directory; prints each input line under it, the directory read as data, never as code
    PREFIX="$1/" awk '{print ENVIRON["PREFIX"] $0}'
}

changed() { # $1: a repository's path; prints its uncommitted .java files as paths under it
    git -C "$1" status --porcelain --untracked-files=all 2>/dev/null \
        | awk '$1 != "D" {print $NF}' | grep '\.java$' | prefix "$1"
}

files=()
if [[ $# -eq 0 ]]; then
    mapfile -t files < <(
        changed "$root"
        git -C "$root" submodule foreach --quiet 'echo "$sm_path"' 2>/dev/null \
            | while IFS= read -r sub; do changed "$root/$sub"; done
    )
elif [[ $1 == --since ]]; then
    mapfile -t files < <(git diff --name-only --diff-filter=d "$2" -- '*.java' | prefix "$root"; changed "$root")
else
    files=("$@")
fi

found=0
for f in "${files[@]}"; do
    [[ -f $f ]] || continue
    out=$(awk '
        /^import[ \t]+(static[ \t]+)?[A-Za-z0-9_$.]+[ \t]*;/ {
            line = $0
            sub(/^import[ \t]+(static[ \t]+)?/, "", line); sub(/[ \t]*;.*/, "", line)
            name = line; sub(/.*\./, "", name)
            if (line in seen) { print FILENAME ":" FNR ": " $0 "  (repeated)"; next }
            seen[line] = 1; n++; at[n] = FNR; text[n] = $0; simple[n] = name
            next
        }
        /^package[ \t]/ { next }
        {
            s = $0; gsub(/[^A-Za-z0-9_$]+/, " ", s)
            k = split(s, w, " "); for (i = 1; i <= k; i++) used[w[i]] = 1
        }
        END { for (i = 1; i <= n; i++) if (!(simple[i] in used)) print FILENAME ":" at[i] ": " text[i] }
    ' "$f")
    if [[ -n $out ]]; then echo "${out//$root\//}"; found=1; fi
done
exit $found
