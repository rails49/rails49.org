#!/usr/bin/env bash
# The gate: CI runs this on every PR.
set -euo pipefail
cd "$(dirname "$0")/.."
# At the tag the pages load the bundle from; a release of look moves both.
pnpm --package=github:rails49/look#v0.15.0 dlx look-check site
