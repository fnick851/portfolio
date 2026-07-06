# Personal portfolio (Noah Song)

Static site: one `index.html` plus vendored `css/`, `font/`, `img/`. No build step, no JS framework, no third-party requests, no analytics. Deployed at a domain root (not GitHub Pages), so keep asset paths relative like `./css/...`.

## css/nes.min.css is a build artifact — do not hand-edit

It is built from my NES.css fork at `~/workspace/others/NES.css` (github.com/fnick851/NES.css, branch `develop`); the file header carries the fork version stamp. To change framework styles: edit the fork's `scss/`, run `npm run build` there, copy its `css/nes.min.css` over this one, and visually verify. Site-specific styles belong in `css/portfolio.css`.

## Performance invariants

- Stylesheets are render-blocking `<link rel="stylesheet">` on purpose — all CSS here is critical. Do not reintroduce async CSS loading (`rel="preload"` + onload swap); that caused the unstyled-flash/CLS problem removed in July 2026.
- Fonts are self-hosted subsets, preloaded in `<head>`:
  - `font/zpix-subset.woff2` contains only the glyphs 宋汉仑历. Adding any other Chinese text requires regenerating it from `font/Zpix.ttf` (v3.1.11, kept unreferenced as the subset source) — the pyftsubset command is documented in `css/portfolio.css`.
  - `font/press-start-2p-latin.woff2` is the Google Fonts v16 latin subset, served locally.

## Link maintenance

Some entries deliberately point at Wayback Machine snapshots because the live products were decommissioned (PatentsView) or removed in a site restructuring (NCES TeacherReports). Before swapping any link to an archive snapshot, open it in a real browser and confirm it actually renders — SPA snapshots often archive the HTML shell without the JS/data (wyoadvances.com is unarchivable for exactly this reason, so it links to the live successor site instead).

## Verifying changes

Serve from the repo root (`python3 -m http.server 8931`) and check in a browser: styled first paint with no flash, 宋汉仑 rendered in the Zpix pixel font, balloons/buttons/containers showing solid pixel borders.
