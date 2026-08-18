#!/usr/bin/env bash
# Open a tracking issue whenever an upstream issue/PR referenced in the repo
# (as a `# https://github.com/<owner>/<repo>/(issues|pull)/<n>` comment) closes.
set -euo pipefail

repo="${GITHUB_REPOSITORY:-vidhanio/vidhanix}"
pattern='https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/(issues|pull)/[0-9]+'

refs="$(git grep -h -oE "$pattern" -I | sort -u || true)"
[ -z "$refs" ] && exit 0

while IFS= read -r ref; do
  case "$ref" in
  "https://github.com/$repo/"*) continue ;; # our own issues and PRs
  esac

  path="${ref#https://github.com/}"
  path="${path%/*}"
  path="${path%/*}"
  num="${ref##*/}"

  state="$(gh api "repos/$path/issues/$num" --jq .state 2>/dev/null || true)"
  [ "$state" = "closed" ] || continue

  # Don't notify twice about the same upstream item.
  if gh search issues --repo "$repo" --state open "$ref" --json number --jq 'length' | grep -q '^[1-9]'; then
    continue
  fi

  gh issue create --repo "$repo" \
    --title "Upstream $path#$num closed" \
    --body "Upstream $ref has been closed. It is referenced in this repo (usually above an ad-hoc patch waiting on the upstream fix); find the references and remove any patches that are no longer needed:

\`\`\`
git grep -n '$ref'
\`\`\`"
done <<<"$refs"
