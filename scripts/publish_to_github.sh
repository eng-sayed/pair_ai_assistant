#!/usr/bin/env bash
# Creates a private GitHub repo and pushes pair_ai_assistant.
# Prerequisites: GitHub CLI (`brew install gh`) and `gh auth login`.
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-eng-sayed}"
REPO_NAME="${REPO_NAME:-pair_ai_assistant}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Log in first: gh auth login"
  exit 1
fi

if gh repo view "${REPO_OWNER}/${REPO_NAME}" >/dev/null 2>&1; then
  echo "Repo ${REPO_OWNER}/${REPO_NAME} already exists — pushing only."
  git push -u origin main
else
  gh repo create "${REPO_OWNER}/${REPO_NAME}" \
    --private \
    --source=. \
    --remote=origin \
    --push \
    --description "Flutter package: embed Pair AI assistant via WebView (mic, camera, files, Arabic)"
fi

echo "Done: https://github.com/${REPO_OWNER}/${REPO_NAME}"
