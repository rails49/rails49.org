#!/usr/bin/env bash
#
# Publish site/ to Cloudflare Pages by direct upload, with no git connection.
#
# There is no build step and nothing generated: what is in git is what reaches
# the web, so nothing runs before the upload and there is no guard in front of
# it. `site/` is the whole of what ships (README.md), and `look/` — beside this
# script rather than inside `site/` — is not served.
#
# The look check is deliberately not run here. It reports that this repository
# has fallen out of step with a decision taken elsewhere, which is not a reason
# to refuse a deploy (ADR-0005 keeps it outside every gate). Run it by hand:
# ./look/values.test.sh
#
set -euo pipefail

cd "$(dirname "$0")"

PROJECT_NAME=rails49-org

# Wrangler's own `login` is not how this authenticates. The credential is an
# API token in 1Password, read at the point of use and never written to disk —
# which is also why a stale OAuth token in ~/Library/Preferences/.wrangler has
# no bearing on whether this works.
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
  if ! command -v op >/dev/null; then
    echo "No CLOUDFLARE_API_TOKEN, and the 1Password CLI is not installed." >&2
    exit 1
  fi
  CLOUDFLARE_API_TOKEN=$(op read "op://rails49/Cloudflare Pages/token")
  CLOUDFLARE_ACCOUNT_ID=$(op read "op://rails49/Cloudflare Pages/account_id")
  export CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID
fi

npx wrangler@3 pages deploy site --project-name="$PROJECT_NAME" --branch=main
