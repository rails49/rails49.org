# rails49.org

The landing page served at the apex of `rails49.org`, and where the project's
end-user documentation will grow.

## Why this repo exists

It started as a directory inside the occupancy repo, and it was never
documentation: `bin/deploy.sh` rsynced `ui/dist/` into it and uploaded the
result, so it was a deploy staging directory that happened to hold a landing
page. Three of that repo's 95 commits ever touched it.

Splitting it out gives every app an origin of its own — `occupancy.rails49.org`
today, `control.rails49.org` when that UI exists — and the apex to the landing
page and the docs. That also dissolves a standing tension in the old setup: the
occupancy app needs `Cross-Origin-Embedder-Policy: require-corp` so onnxruntime
can use more than one WASM thread, and this page loads Google Fonts
cross-origin, which `require-corp` blocks. Sharing an origin meant scoping the
header to `/ui/*` and keeping the two halves out of each other's way. On
separate origins each simply sets what it needs, and this repo needs no
`_headers` at all.

See [rails49/control#47](https://github.com/rails49/control/issues/47).

## The look

The band across the top and the colours it draws with are not this site's to
choose: four rails49 UIs are bound to one set of values so that a person
clicking from here to `occupancy` does not cross into a different-looking
project. [`look/`](look/README.md) holds those values, copied verbatim from
`rails49/.github` at a recorded commit, and `look/values.test.sh` asserts that
both pages draw with them. Run it by hand after touching a page's colours:

```
./look/values.test.sh
```

It never fetches, so it fails only on a local edit.

## Deploying

Direct upload to Cloudflare Pages, with no git connection:

```
npx wrangler@3 pages deploy site --project-name=rails49-org --branch=main
```

`site/` is the whole of what ships, and it is the reason the deploy is one line
with no guard in front of it: there is no build step and nothing generated, so
what is in git is what reaches the web. That only holds while the publishable
content and the repo's own files stay separated — `README.md` at the root is
not served, and anything added beside it is not served either. Put a file in
`site/` and it is public.
