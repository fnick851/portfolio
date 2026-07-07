# Personal portfolio (Noah Song)

Static site: one `index.html` plus vendored `css/`, `font/`, `img/`. No build step, no JS framework, no third-party requests, no analytics. Deployed at https://portfolio.noah-song.com/ (domain root, not GitHub Pages) — keep asset paths relative like `./css/...`; if the domain ever changes, the canonical and `og:*` URLs in `index.html` must change with it.

Owner's standing requirements: good engineering practice with zero tolerance for rot (dead links, dead code, outdated dependencies), and long-term durability as a public showcase. Prefer boring, durable choices over trendy ones. The project must stay maintainable by less capable AI models: keep conventions explicit in this file (always with the *why*), keep invariants executable in `./check.sh`, and when you add or change an invariant, update both.

## css/nes.min.css is a build artifact — do not hand-edit

It is built from my NES.css fork at `~/workspace/others/NES.css` (github.com/fnick851/NES.css, branch `develop`); the file header carries the fork version stamp. To change framework styles: edit the fork's `scss/`, run `npm run build` there, copy its `css/nes.min.css` over this one, and visually verify. Site-specific styles belong in `css/portfolio.css`.

## Adding entries

Entry buttons are anchors styled by NES.css: `<a class="nes-btn is-success" href="..." target="_blank" rel="noopener noreferrer">Label</a>`. Never nest a `<button>` inside an `<a>` — that older pattern was removed in July 2026 (invalid HTML, double tab stops).

## Performance invariants

- Stylesheets are render-blocking `<link rel="stylesheet">` on purpose — all CSS here is critical. Do not reintroduce async CSS loading (`rel="preload"` + onload swap); that caused the unstyled-flash/CLS problem removed in July 2026.
- Fonts are self-hosted subsets, preloaded in `<head>`:
  - `font/zpix-subset.woff2` contains only the glyphs 宋汉仑历. Adding any other Chinese text requires regenerating it from `font/Zpix.ttf` (v3.1.11, kept unreferenced as the subset source) — the pyftsubset command is documented in `css/portfolio.css`.
  - `font/press-start-2p-latin.woff2` is the Google Fonts v16 latin subset, served locally.

## Link maintenance

Some entries deliberately point at Wayback Machine snapshots because the live products were decommissioned (PatentsView) or removed in a site restructuring (NCES TeacherReports). Before swapping any link to an archive snapshot, open it in a real browser and confirm it actually renders — SPA snapshots often archive the HTML shell without the JS/data (wyoadvances.com is unarchivable for exactly this reason, so it links to the live successor site instead).

## Verifying changes

1. Run `./check.sh` — it mechanically enforces the invariants above (no nested buttons, render-blocking CSS, assets exist, fork-stamped nes.min.css, https-only, no duplicate attributes, canonical/og URL). It must pass before any commit.
2. Serve from the repo root (`python3 -m http.server 8931`) and check in a browser: styled first paint with no flash, 宋汉仑 rendered in the Zpix pixel font, balloons/buttons/containers showing solid pixel borders.
