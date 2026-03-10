#!/usr/bin/env bash
set -euo pipefail

# Post a failure comment on the PR with typed error messages.
# Inputs (env vars): GH_TOKEN, REPO, PR_NUMBER, RUN_URL, MAX_TURNS, TIMEOUT_MINUTES

OUTPUT_FILE="/home/runner/work/_temp/claude-execution-output.json"

if [ -f "$OUTPUT_FILE" ]; then
  # Output may be a JSON array or object — normalize to object
  ERROR_TYPE=$(jq -r '(if type == "array" then last else . end) | .subtype // empty' "$OUTPUT_FILE")

  case "$ERROR_TYPE" in
    error_max_turns)
      BODY="⚠️ Review incomplete — Claude hit the ${MAX_TURNS} turn limit. The PR may be too large or complex for automated review. [Action logs](${RUN_URL})"
      ;;
    *)
      BODY="⚠️ Claude review failed. Check the [action logs](${RUN_URL}) for details."
      ;;
  esac
else
  BODY="❌ Review failed — no execution output produced. This usually means the workflow file on this branch differs from the default branch. Check the [workflow run](${RUN_URL})."
fi

gh pr comment "$PR_NUMBER" --repo "$REPO" --body "$BODY" || true
echo "::notice::Failure comment posted: ${ERROR_TYPE:-no-output}"
