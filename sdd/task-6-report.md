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

## Blocking review fix

Bound each redirect expectation to the relevant generated HTML attribute instead of accepting the target anywhere in the document:

- refresh: the `meta[http-equiv="refresh"]` `content` value must resolve exactly to the expected relative fragment target;
- canonical: the canonical `link` `href` must equal the configured absolute site URL plus the expected fragment;
- fallback: the anchor containing `继续前往` must have the exact expected relative fragment in `href`.

Commands and results:

- Before the fix, the focused Python regression harness exited 1 with `RED: current verifier accepts redirect targets supplied by an unrelated element`.
- After the fix, the focused Python attribute-binding harness passed a correct redirect and rejected mismatched refresh, canonical, and fallback targets: `PASS: correct redirect passes and three mismatched attribute targets fail`.
- Review follow-up tightened attribute extraction to the opening element with exact attribute names; its focused harness rejected `data-*` lookalikes and descendant `href` values: `PASS: exact opening-element attributes required`.
- Final static source-contract checks: passed.
- `git diff --check`: passed.
- Ruby/Jekyll execution remains unavailable for the reasons above.
