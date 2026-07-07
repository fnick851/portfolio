#!/bin/bash
# Static invariant checks for this portfolio. Run from anywhere: ./check.sh
# Zero dependencies (POSIX tools only). Each rule states its reason;
# CLAUDE.md has the full context. Exit 0 = all good, 1 = violations.
set -u
cd "$(dirname "$0")" || exit 1

fails=0
fail() { echo "FAIL: $1"; fails=$((fails + 1)); }
ok()   { echo "ok:   $1"; }

# --- 1. Buttons are styled anchors. <button> inside <a> is invalid HTML and
#        creates double tab stops (pattern removed July 2026).
if grep -q '<button' index.html; then
  fail "index.html contains <button> tags — use <a class=\"nes-btn ...\"> instead"
else
  ok "no nested <button> tags"
fi

# --- 2. CSS must stay render-blocking. The preload+onload swap trick caused
#        the unstyled-flash/layout-shift bug (removed July 2026).
if tr '\n' ' ' < index.html | grep -oE '<link[^>]*>' | grep -E 'as="style"|onload' | grep -q .; then
  fail "async CSS loading pattern found — stylesheets must be plain render-blocking <link rel=\"stylesheet\">"
else
  ok "CSS is render-blocking"
fi

# --- 3. Every local asset referenced by index.html and portfolio.css exists.
missing=0
for f in $(grep -oE '\./(css|font|img)/[A-Za-z0-9._-]+' index.html | sed 's|^\./||' | sort -u) \
         $(grep -oE '\.\./font/[A-Za-z0-9._-]+' css/portfolio.css | sed 's|^\.\./||' | sort -u); do
  if [ ! -f "$f" ]; then
    fail "referenced asset missing on disk: $f"
    missing=1
  fi
done
[ "$missing" -eq 0 ] && ok "all referenced local assets exist"

# --- 4. nes.min.css must be the fork's build (never the npm one) — the fork
#        carries local fixes. The fork stamps its version into the header.
if head -c 300 css/nes.min.css | grep -q "fork"; then
  ok "nes.min.css is a fork build ($(head -c 300 css/nes.min.css | grep -oE 'Version: [^ ]*fork[^ ]*'))"
else
  fail "css/nes.min.css has no fork version stamp — was it overwritten with a non-fork build?"
fi

# --- 5. All links are https (no plain http).
if grep -q 'href="http://' index.html; then
  fail "plain http:// link found"
else
  ok "all links are https"
fi

# --- 6. No duplicate attributes within a tag (e.g. two rel= on one anchor).
if tr '\n' ' ' < index.html | grep -oE '<[a-z]+ [^>]*>' | grep -E '(rel="[^"]*"[^>]*rel=|target="[^"]*"[^>]*target=|class="[^"]*"[^>]*class=)' | grep -q .; then
  fail "duplicate attribute (rel/target/class) on a single tag"
else
  ok "no duplicate attributes"
fi

# --- 7. Canonical and og:url must match the deploy URL (CLAUDE.md: if the
#        domain changes, these change with it).
url="https://portfolio.noah-song.com/"
n=$(grep -cE "(href|content)=\"$url\"" index.html)
if [ "$n" -ge 2 ]; then
  ok "canonical + og:url point at $url"
else
  fail "canonical/og:url do not both match $url"
fi

echo
if [ "$fails" -eq 0 ]; then
  echo "all checks passed"
else
  echo "$fails check(s) failed"
  exit 1
fi
