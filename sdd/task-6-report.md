# Task 6 Report — maintenance guide and final static verification

## Status

Implemented Task 6 after cherry-picking all ten supplied prerequisite commits in the requested order.

## SHA

This report is contained in the Task 6 documentation commit; resolve the final SHA with `git rev-parse HEAD`.

## Tests

- Static README/verifier contract check: passed. It confirms the required README sections `本地预览`、`写文章`、`添加项目`、`独立域名`, the documented operational commands and deployment/domain safeguards, and the corresponding exact section words in `scripts/verify_site.rb`.
- `git diff --check`: passed.
- `bundle exec jekyll build`: not run successfully because Bundler is unavailable: `bundle: command not found`.
- `ruby scripts/verify_site.rb`: not run successfully because Ruby is unavailable: `ruby: command not found`.
- No browser or manual responsive tests were performed because the required Ruby/Bundler local site environment is unavailable.

## Concerns

Run `bundle exec jekyll build && ruby scripts/verify_site.rb` in a Ruby/Bundler-enabled environment before release. The final Ruby verifier reads the README and checks that all four required Chinese section words are present before it checks generated site output.

## Report

This file records the final Task 6 result.

## Review Finding Follow-up

- Updated the `README.md` 独立域名 sequence with a single explicit step to create the root-level `CNAME` file only after the DNS and actual domain are confirmed; its entire content must be the selected domain, such as `www.example.com`.
- Kept the existing warning against committing `CNAME` before a real domain is configured and renumbered the subsequent Enforce HTTPS and retest steps.
- Focused static text check: passed.
- `git diff --check`: passed.
- Ruby and Bundler remain unavailable in this environment, so the existing Jekyll build and Ruby verifier were not run.
