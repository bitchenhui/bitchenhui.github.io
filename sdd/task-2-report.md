# Task 2 Report

## Status

Implemented the focused Liquid includes required by Task 2 and preserved the structured, personalized values introduced in Task 1. Component source contracts are now checked before generated-site checks.

## Files

- Created `_includes/profile-card.html`: consumes `site.author`, `site.current_focus`, and `site.skills`; normalizes optional contact URLs and renders only non-empty links.
- Created `_includes/experience-item.html`: consumes the Task 1 experience shape through `include.item` and escapes all displayed values.
- Modified `_includes/project-card.html`: preserves URL normalization and conditional actions while adding secure relationship attributes and explicit new-window labels.
- Modified `_includes/post-card.html`: adds metadata/action classes and exactly one explicit `阅读全文` action.
- Modified `scripts/verify_site.rb`: adds required component source-marker checks before the `_site` guard.
- Updated `sdd/task-2-report.md`: records this task's implementation and evidence.

## Commands and Results

### TDD red phase

- `ruby scripts/verify_site.rb`
  - Blocked before execution: exit 127, `ruby: command not found`.
- Static equivalent confirming the intended missing-component failure before implementation:
  - Result: exit 1, `FAIL: _includes/profile-card.html is missing.`

### Green and verification phase

- `ruby scripts/verify_site.rb`
  - Blocked: exit 127, `ruby: command not found`.
- `bundle exec jekyll build`
  - Blocked: exit 127, `bundle: command not found`.
- Python static component checks covering required markers, data interfaces, valid-only external actions, explicit labels, `noopener noreferrer`, and the single `阅读全文` label
  - Result: `PASS: Task 2 static component contracts and valid-only link guards verified.`
- Fresh compact Python source-contract check
  - Result: `PASS: Task 2 source contracts and guarded external actions verified.`
- `git diff --check`
  - Result: exit 0; no whitespace errors. Git emitted only an LF-to-CRLF working-copy warning for `_includes/post-card.html`.
- `git status --short`
  - Confirmed only the five Task 2 implementation files and this required report are changed.

## Commit

- Commit identifier: this report is included in the Task 2 commit; the resulting hash is supplied in the final task response.
- Message: `feat: add personal manual components`
- Trailer: `Co-Authored-By: Claude <noreply@anthropic.com>`

## Self-Review

- Compared the implementation line by line with `task-2-brief.md`.
- Confirmed source checks run before the `_site` guard.
- Confirmed optional profile links are stripped before comparison and emitted only when non-empty.
- Confirmed project actions remain conditional on normalized non-empty URLs.
- Confirmed each external new-window link includes `noopener noreferrer` and a visible new-window label.
- Confirmed displayed data is escaped as required.
- Confirmed the post card emits exactly one visible `阅读全文` label while retaining the linked title specified by the brief.
- Confirmed no personalized values were overwritten; includes consume existing configuration/data.
- Independent code review reported no Critical, Important, or Minor findings.
- Confirmed no unrelated implementation files were changed.

## Concerns

- Ruby and Bundler are unavailable, so neither the Ruby verifier nor a Jekyll build could run. Ruby/Jekyll success is not claimed.
- Static checks validate source contracts and guarded link structure but cannot replace Liquid rendering through Jekyll.
- Git reports that `_includes/post-card.html` may be converted from LF to CRLF the next time Git touches it; `git diff --check` remains clean.
