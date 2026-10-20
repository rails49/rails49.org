# rails49.org

The landing page served at the apex of `rails49.org`, and where the project's
end-user documentation will grow.

## Why this repo exists

It started as a directory inside the occupancy repo, and it was never
documentation: `bin/deploy.sh` rsynced `ui/dist/` into it and uploaded the
result, so it was a deploy staging directory that happened to hold a landing
page. Three of that repo's 95 commits ever touched it.

Splitting it out gives occupancy an origin of its own, `occupancy.rails49.org`,
and the apex to the landing page and the docs. That also dissolves a standing
tension in the old setup: the
occupancy app needs `Cross-Origin-Embedder-Policy: require-corp` so onnxruntime
can use more than one WASM thread, and this page loads Google Fonts
cross-origin, which `require-corp` blocks. Sharing an origin meant scoping the
header to `/ui/*` and keeping the two halves out of each other's way. On
separate origins each simply sets what it needs, and this repo needs no
`_headers` at all.

The control UI is not one of the project's own sites: each installation serves
it at `control.<box name>` (org
[ADR-0007](https://github.com/rails49/.github/blob/main/docs/adr/0007-an-installation-is-a-name-and-every-ui-is-a-label-under-it.md)).

See [rails49/control#47](https://github.com/rails49/control/issues/47).

## The look

The band across the top is not this site's to draw. Both pages load
[look](https://github.com/rails49/look)'s single-file build from jsDelivr at a
tag and put `look-band` in a `look-shell`, so a person clicking from here to
`occupancy` sees the same band. There is no rail: the site offers nothing to
press. The rest of each page is the site's own.

CI runs `look-check` on `site/`. It fails on a selector naming a `look-`
element, on setting one of look's tokens or a `--sl-*` property, and on
`sl-*::part()`. To run it locally:

```
pnpm --package=github:rails49/look#v0.7.0 dlx look-check site
```

A look release opens a pull request here that moves the tag in the pages and
the workflow.

## Deploying

Direct upload to Cloudflare Pages, with no git connection:

```
./deploy.sh
```

Which is that one line of `wrangler`, plus the part that is easy to forget:
the Cloudflare credential is an API token in 1Password, read at the point of
use. Wrangler's own `login` is not involved, so a stale OAuth token in
`~/Library/Preferences/.wrangler` says nothing about whether a deploy will
work.

`site/` is the whole of what ships, and it is the reason the deploy is one line
with no guard in front of it: there is no build step and nothing generated, so
what is in git is what reaches the web. That only holds while the publishable
content and the repo's own files stay separated — `README.md` at the root is
not served, and anything added beside it is not served either. Put a file in
`site/` and it is public.
