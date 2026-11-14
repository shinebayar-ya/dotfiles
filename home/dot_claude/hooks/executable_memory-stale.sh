#!/bin/bash
# SessionStart: name memories whose referenced code changed in git since the last check.
# Runs at most once per 7 days; prints nothing when nothing matches, so it costs no tokens then.
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
mem="$HOME/.claude/projects/$(printf %s "$dir" | sed 's/[^A-Za-z0-9]/-/g')/memory"
mark="$mem/.last-check"
[ -d "$mem" ] || exit 0
[ -n "$(find "$mark" -mtime -7 2>/dev/null)" ] && exit 0
since=$(stat -f %m "$mark" 2>/dev/null || date -v-7d +%s)
touch "$mark"

files=$(git -C "$dir" log --since="@$since" --name-only --format= 2>/dev/null | sort -u)
[ -n "$files" ] || exit 0
diff=$(git -C "$dir" log --since="@$since" -p --format= 2>/dev/null | grep -E '^[+-][^+-]')

# shortcut: matches names only (class = changed file name, snake_case = changed diff line), not meaning; upgrade if it misses or nags.
out=""
for f in "$mem"/*.md; do
  [ "${f##*/}" = MEMORY.md ] && continue
  hits=""
  for t in $(grep -o '`[^`]*`' "$f" | grep -oE '[A-Za-z][A-Za-z0-9_]{3,}' | sort -u); do
    if [[ $t =~ ^[A-Z] && $t =~ [a-z] ]] && grep -qE "(^|/)$t\.[a-z]+$" <<<"$files"; then
      hits="$hits $t"
    elif [[ $t == *_* ]] && grep -qw -- "$t" <<<"$diff"; then
      hits="$hits $t"
    fi
  done
  [ -n "$hits" ] && out="$out\n- ${f##*/}:$hits"
done
[ -n "$out" ] && printf "Memory check: code changed since %s touches these memories (matched names). Verify each against the code; update or delete stale ones and their MEMORY.md line.%b\n" "$(date -r "$since" +%F)" "$out"
exit 0
