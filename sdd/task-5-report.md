# Task 5 Report — feed, sitemap, robots, and not-found page

## Status

Implemented amended Task 5 after cherry-picking all nine required prerequisite commits in the supplied order.

## Changes

- Added `404.html` using `layout: page`, title `页面未找到`, permalink `/404.html`, a Chinese explanatory sentence, and a `.button` home link labeled `返回首页`.
- Added `robots.txt` with the exact required crawler directives and canonical sitemap URL.
- Kept `feed.xml` and `sitemap.xml` absent from the source tree. `_config.yml` already enables `jekyll-feed` and `jekyll-sitemap`, which generate those output routes during the Jekyll build.
- Extended `scripts/verify_site.rb` after its existing checks to validate rendered 404, feed, robots, and sitemap content. The pre-existing required output route list and checks remain intact.
- Did not add CNAME, `.nojekyll`, a framework, server, database, or GitHub Actions workflow.

## Validation

- Static focused contract check: passed. It checks the 404 front matter/content/button, exact robots content, absence of source `feed.xml`/`sitemap.xml`, configured plugins, new verifier markers, and prohibited deployment artifacts.
- `git diff --check`: passed.
- `ruby scripts/verify_site.rb`: could not run because Ruby is unavailable (`ruby: command not found`).
- `bundle exec jekyll build`: could not run because Bundler is unavailable (`bundle: command not found`).

## Concern

Run `bundle exec jekyll build && ruby scripts/verify_site.rb` in a Ruby/Bundler-enabled environment to exercise Jekyll plugin-generated `feed.xml` and `sitemap.xml` output.
