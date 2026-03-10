#!/usr/bin/env bash
set -euo pipefail

# Fetch review guide from default branch, fallback to PR branch working copy.
# Inputs (env vars): GH_TOKEN, REPO, GUIDE_PATH, DEFAULT_BRANCH
# Outputs: /tmp/review-guide.md (file on disk)

# Auto-detect default branch if not provided
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH=$(gh api "repos/${REPO}" --jq '.default_branch')
  echo "::notice::Auto-detected default branch: $DEFAULT_BRANCH"
fi

# Save the PR branch version if it exists (before we overwrite)
if [ -f "$GUIDE_PATH" ]; then
  cp "$GUIDE_PATH" /tmp/guide-pr-branch.md
fi

# Try default branch first (preferred — ensures guide is the approved version)
gh api "repos/${REPO}/contents/${GUIDE_PATH}?ref=${DEFAULT_BRANCH}" \
  --jq '.content' | base64 -d > /tmp/review-guide.md 2>/dev/null || true

# Fallback: restore PR branch copy if default branch fetch failed/empty
if [ ! -s /tmp/review-guide.md ] && [ -f /tmp/guide-pr-branch.md ]; then
  echo "::notice::Review guide not found on ${DEFAULT_BRANCH}, using PR branch copy"
  cp /tmp/guide-pr-branch.md /tmp/review-guide.md
fi

# Final validation
if [ ! -s /tmp/review-guide.md ]; then
  echo "::error::Review guide '${GUIDE_PATH}' not found on ${DEFAULT_BRANCH} or PR branch"
  exit 1
fi

echo "::notice::Review guide loaded ($(wc -c < /tmp/review-guide.md | tr -d ' ') bytes)"
