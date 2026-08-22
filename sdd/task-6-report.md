# Task 6 Report — generated-site verification

## Status

Implemented the Task 6 verifier rewrite. `scripts/verify_site.rb` now keeps source contracts ahead of the `_site` prerequisite, checks the approved generated single-page homepage and complete project/post listings, validates generated legacy redirects, and retains the eleven required outputs plus language, viewport, non-empty-link, article, 404, feed, robots, and sitemap checks.

## TDD evidence

- RED: an inline Python source-contract harness failed before the edit because the verifier lacked the generated profile marker, project/post title checks, redirect-output map, refresh metadata, and canonical metadata.
- GREEN: the same source-contract harness passed after the edit.
- `_site` is absent, confirming that generated verification still requires a fresh build.

## Tests

- Task 6 static verifier contract harness: passed.
- `git diff --check`: passed.
- `_site` prerequisite check: passed (`_site` is absent).
- Independent code review: no concrete findings.
- `ruby scripts/verify_site.rb`: not run; `ruby: command not found`.
- `bundle exec jekyll build`: not run; `bundle: command not found`.

## Concerns

Ruby, Bundler, and Jekyll are unavailable in this environment. Run `bundle exec jekyll build && ruby scripts/verify_site.rb` in a Ruby-enabled environment before release; generated HTML assertions have not been executed here.
