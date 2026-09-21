# The look rules' values, copied

`tokens.css` beside this file is a **verbatim copy** of
[`docs/tokens.css`](https://github.com/rails49/.github/blob/main/docs/tokens.css)
in `rails49/.github`, taken at:

    c91e9bea6680808edab65675998ab49ea6309cd3

[ADR-0005](https://github.com/rails49/.github/blob/main/docs/adr/0005-the-look-rules-travel-as-a-copied-file-not-a-package.md)
decides that nothing is installed: every consumer copies the file, records the
commit it came from, and keeps a check asserting that the values it actually
draws with equal the copy's. The recorded commit is the pin a git dependency
would have given.

This site is the reason the mechanism is a copy at all. It is two static pages
with an inline `<style>` block each, no `package.json`, no lockfile and no
build, so no package of any kind could reach it without giving it a toolchain
it does not need.

## What this site takes

Tokens and the band. No rail, since the site offers nothing to press
([LOOK.md](https://github.com/rails49/.github/blob/main/docs/LOOK.md),
[ADR-0003](https://github.com/rails49/.github/blob/main/docs/adr/0003-the-look-rules-bind-place-colour-and-small-screens-not-code.md)).
Its stack is free, and so is what the rest of each page looks like.

So `--band` and `--band-ink` are declared in each page's `:root` and the band
draws with them. The four rail values are **deliberately absent**: there is no
rail here for them to be the size or colour of, and a value nothing draws with
is a value that can drift unseen. `values.test.sh` compares only the two.

LOOK.md's table names the landing page, and `404.html` takes the same two for
the same reason the rules exist: a person who mistypes a path has not left the
project, and a page in a palette of its own would say they had. Two pages is
what the check covers.

## The copy is inert

Nothing links `tokens.css` and no page loads it — `values.test.sh` reads it.
How this site expresses the values is its own business (ADR-0003): they are two
custom properties in an inline `<style>` block, which is all this site has.

## The check runs by hand

```bash
./look/values.test.sh
```

It never fetches, so it cannot go red on someone else's commit in `.github`; it
fails only when a value here is edited. That, and the fact that a drift check
reports a repository falling out of step with a decision taken elsewhere, is
why ADR-0005 keeps it outside any required gate. Deploying stays the one line
the [repository README](../README.md) gives.

## Taking a change

`.github` announces a change by filing an issue here; nothing is scheduled and
nothing is automated. To take one: replace `tokens.css` with the new file
verbatim, write the new commit above, run the check, and change whatever it
reports. A token that arrives with no expression here fails the first
assertion rather than being quietly ignored.
