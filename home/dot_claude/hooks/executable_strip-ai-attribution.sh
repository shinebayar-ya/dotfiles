#!/usr/bin/env bash
# strip-ai-attribution.sh
#
# Claude Code PreToolUse hook for the Bash tool.
# Strips AI co-author / attribution lines from `git commit` commands
# before they execute, regardless of -m / HEREDOC form.
#
# Idempotent. Passthrough when:
#   - command is not a git commit
#   - no AI markers present
#
# Patterns stripped (case-sensitive — markers are always fixed-case):
#   - Co-Authored-By: Claude...
#   - Co-Authored-By: Anthropic...
#   - Co-Authored-By: ... <noreply@anthropic.com>
#   - Generated with Claude Code
#   - 🤖 Generated with...

set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

# Fast-exit: not a git commit invocation
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# Strip matching lines. `|| true` keeps the script alive when grep matches everything.
stripped=$(
  printf '%s' "$cmd" \
    | grep -vE 'Co-Authored-By:[[:space:]]+(Claude|Anthropic)|Co-Authored-By:.*noreply@anthropic\.com|Generated with Claude Code|🤖 Generated with' \
    || true
)

# Nothing changed — passthrough
if [ "$stripped" = "$cmd" ]; then
  exit 0
fi

# Emit JSON with the modified command. Schema:
#   hookSpecificOutput.hookEventName = "PreToolUse"
#   hookSpecificOutput.updatedInput   = new tool_input (merged)
printf '%s' "$input" | jq --arg new "$stripped" '
  . + {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "updatedInput": (.tool_input + {"command": $new})
    }
  }
'
