#!/usr/bin/env bash
#
# The look rules bind four UIs to six values (ADR-0003), and those values travel
# as a copied file rather than a package (ADR-0005): `tokens.css` beside this
# script is `rails49/.github`'s, verbatim, at the commit `README.md` records.
#
# This is the check that ADR asks every consumer for. It **never fetches** — it
# compares what these pages draw with against the copy on disk, so it fails only
# on a local edit and cannot go red on someone else's commit in `.github`.
#
# It is a shell script because this repository has no toolchain to hang a test
# runner on: two static pages with an inline `<style>` block each, no
# `package.json`, no lockfile, no build. That is the same fact that made a
# copied file the only mechanism that could reach this site at all.
#
#     ./look/values.test.sh
#
set -uo pipefail

cd "$(dirname "$0")/.."

copy=look/tokens.css
pages=(site/index.html site/404.html)

# The six the rules define. An upstream addition arriving in a sync fails here
# rather than being quietly ignored: the copy is the only thing that changes,
# and nothing else would notice a seventh token nothing expresses.
expected=(--band --band-ink --rail --rail-button --rail-group --rail-turns)

# The two this site draws. It takes the tokens and the band and no rail, since
# it offers nothing to press (LOOK.md, ADR-0003), so the four rail values have
# nothing here to equal and are deliberately absent from the pages.
drawn=(--band --band-ink)

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# A stylesheet with its comments gone, so prose that happens to look like a
# declaration — or to quote a value — cannot be mistaken for one.
without_comments() {
  perl -0777 -pe 's{/\*.*?\*/}{}gs' "$1"
}

# Every `--name: value` in a stylesheet, one per line.
declarations() {
  without_comments "$1" |
    grep -oE -- '--[A-Za-z0-9-]+[[:space:]]*:[[:space:]]*[^;}]+' |
    sed -E 's/[[:space:]]*:[[:space:]]*/ /; s/[[:space:]]+$//'
}

value_of() {
  declarations "$1" | awk -v name="$2" '$1 == name { $1 = ""; sub(/^ /, ""); print; exit }'
}

names_in() {
  declarations "$1" | awk '{ print $1 }' | LC_ALL=C sort -u | tr '\n' ' ' | sed -E 's/ $//'
}

for page in "${pages[@]}" "$copy"; do
  [ -f "$page" ] || {
    fail "$page does not exist"
    exit 1
  }
done

# 1. The copy holds exactly the tokens the rules define.
actual=$(names_in "$copy")
[ "$actual" = "${expected[*]}" ] ||
  fail "$copy declares [$actual]; the rules define [${expected[*]}]"

band=$(value_of "$copy" --band)

for page in "${pages[@]}"; do
  # 2. Each page draws the bound values with the copy's values.
  for name in "${drawn[@]}"; do
    want=$(value_of "$copy" "$name")
    got=$(value_of "$page" "$name")
    if [ -z "$got" ]; then
      fail "$page declares no $name"
    elif [ "$got" != "$want" ]; then
      fail "$page draws $name as '$got'; the copy says '$want'"
    fi
  done

  # 3. Neither page keeps a second copy of the band's value. The teal palette
  #    this replaced is what the rules exist to stop: a literal that drifts on
  #    its own with nothing to report it. Occurrences, not matching lines —
  #    `grep -c` would call two of them on one line one, and on GNU grep it
  #    ignores `-o` and does exactly that.
  #
  #    Only `--band`. `--band-ink` is `#ffffff`, which these pages write several
  #    times over for reasons that have nothing to do with the band, and a check
  #    that cried about every white would be turned off rather than obeyed.
  count=$(without_comments "$page" | grep -ioF -- "$band" | wc -l | tr -d ' ')
  [ "$count" = 1 ] ||
    fail "$page writes $band $count times; the declaration of --band is the only place it belongs"

  # 4. The band exists, and the operating system decides the scheme. Not values,
  #    but the rules the values sit inside: a token the chrome keeps in both
  #    themes means nothing on a page that has one theme, or no band.
  grep -q 'class="band"' "$page" || fail "$page draws no band"
  grep -q 'prefers-color-scheme: dark' "$page" ||
    fail "$page follows no prefers-color-scheme"
done

if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed" >&2
  exit 1
fi

echo "the look rules: ${#pages[@]} pages draw the copy's values"
