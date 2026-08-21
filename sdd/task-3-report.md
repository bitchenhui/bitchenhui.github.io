# Task 3 Report — portfolio data and reusable project/post presentation

## Scope

Task 3 adds Jekyll-native reusable content primitives only. It does not create public project or blog pages/posts.

### Prerequisites applied

The requested prerequisite commits were available and cherry-picked first:

1. `128777e4d7d17b3098b3edce209af640c15fc483` → local commit `1973027` (`chore: configure Jekyll site build`)
2. `354f950f9110ea77be2ccce41c07e169717cb899` → local commit `1752b1f` (`feat: add responsive site shell and theme toggle`)

## Changed files

- `_data/projects.yml`
  - Adds exactly three Chinese illustrative records: 视频编码优化工具、性能分析平台、个人开源工具.
  - Each record has a Chinese explicit `TODO: 替换为真实项目。示例：...` description, the required three-item stack, `featured: true`, and empty string project/repository URLs.
  - The descriptions are labelled placeholders, so they make no claims about real work.

- `_includes/project-card.html`
  - Defines an `<article>` project card.
  - Escapes title, description, and stack values.
  - Omits the stack list when no stack is supplied.
  - Omits the action container unless at least one URL is nonempty; each external link is separately guarded and uses `target="_blank" rel="noopener"`.

- `_includes/post-card.html`
  - Defines an `<article>` post card with Chinese-formatted date and XML-compatible `datetime`.
  - Links escaped titles through `include.post.url | relative_url`.
  - Normalizes and escapes the configured description or fallback excerpt.
  - Renders tags only when supplied and nonempty.

- `_layouts/page.html`
  - Adds front matter selecting `default`, then a semantic titled section.

- `_layouts/post.html`
  - Adds front matter selecting `default`, a `/blog/` return link, Chinese-formatted date with XML `datetime`, escaped title, optional tag list, and the post body.

- `scripts/verify_site.rb`
  - Retains all existing checks and, after them, asserts that `_data/projects.yml` exists and includes `featured: true` plus `TODO: 替换为`.

## TDD and verification evidence

### Initial verifier attempt (RED baseline)

```text
$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

Ruby is unavailable in this environment, so the generated-site verifier cannot be run locally.

### Focused pre-implementation static check (RED)

```text
$ test -f _data/projects.yml && ...
Exit code 1
```

The check intentionally failed before implementation because the required Task 3 files did not exist.

### Focused static requirements check (GREEN)

```text
PASS: verified Task 3 data, reusable templates, layouts, and verifier checks.
Exit code 0
```

This check confirms exact record count/markers, escaped Liquid rendering, conditional URL/tag/stack markup, layouts, verifier markers, and absence of `.nojekyll`/`CNAME`.

### Whitespace and diff inspection

```text
$ git diff --check
Exit code 0
```

The Task 3 diff was also inspected directly. No public pages or posts are included.

### Independent review

A focused review of the current Task 3 changes reported no actionable defects.

## Concerns

- Ruby, Bundler, and Jekyll are not installed, so `bundle exec jekyll build` and `ruby scripts/verify_site.rb` still require execution in an environment with the project's Ruby dependencies.
- The project cards deliberately render no external controls for the supplied placeholder records because both URLs are blank; this satisfies the no-empty-`href` constraint.

## Review-finding follow-up — 2026-08-21

### Fixes applied

- `_includes/project-card.html` now normalizes `project_url` and `repository_url` through `default: "" | strip`, tests them against `""`, and renders every external link from its normalized assigned value. Omitted, nil, blank, and whitespace-only values therefore cannot produce an empty `href`.
- Project and post cards now consume the existing `card` base CSS class, and each rendered tag consumes the existing `tag` CSS class.
- Page and post layouts now use the existing `section`, `shell`, and `prose` CSS classes while retaining their existing semantic elements, escaped titles/tags, optional tags, return link, date output, and content output.
- `scripts/verify_site.rb` now validates `_data/projects.yml` before it checks for `_site` and generated routes; every prior check remains in place.

### Verification results

```text
$ python [focused static review regression check]
PASS: Task 3 review regression contracts
Exit code 0

$ git diff --check
Exit code 0

$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

Ruby remains unavailable in this environment. The exact verifier command could not execute; the focused static check verifies the requested Liquid assignments/guards, assigned URL use, CSS-class contracts, source escaping, and verifier ordering.

### Follow-up concerns

- Full Jekyll build and generated-site verification still require Ruby, Bundler, and the project dependencies in another environment.

## Remaining template-class review follow-up — 2026-08-21

### Fix applied

- Removed only unsupported classes from reusable content templates/layouts: `project-card`, `project-card__stack`, `project-card__actions`, `post-card`, `post-header`, and `post-content`. Existing `card`, `tag-list`, `tag`, `section`, `shell`, and `prose` classes and the original semantic elements remain intact.

### Verification results

```text
$ rg "(project-card|project-card__stack|project-card__actions|post-card|post-header|post-content)" _includes/project-card.html _includes/post-card.html _layouts/post.html
No matches found

$ rg "\\.(project-card|project-card__stack|project-card__actions|post-card|post-header|post-content)" assets/css/main.scss
No matches found

$ git diff --check
Exit code 0
```

The focused checks prove each removed class is absent from the three target templates/layout and that `main.scss` defines none of their selectors.

### Follow-up concerns

- Full Jekyll build and generated-site verification remain blocked locally because Ruby, Bundler, and the project dependencies are unavailable.

## Final Task 3 contract corrections — 2026-08-21

### Corrections applied

- `scripts/verify_site.rb` retains its project-data assertions before `_site` validation and now emits the required exact error messages.
- `_includes/project-card.html` retains `card`, uses an `h3` title, applies `tag-list`/`tag` to the stack, and applies `button-row` plus `button button-secondary` to guarded external actions.
- `_includes/post-card.html` retains `card` and tag classes while using an `h3` title.
- `_layouts/page.html` and `_layouts/post.html` retain existing semantics and content while adding `section-heading` to their `h1` elements.

### Verification results

```text
$ python [exact Task 3 content-model contract check]
PASS: exact Task 3 content-model contracts
Exit code 0

$ git diff --check
Exit code 0

$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

### Concerns

- Ruby remains unavailable in this environment, so the Ruby verifier and Jekyll build cannot run locally.

## Final corrective fix — 2026-08-21

### Prerequisites

Cherry-picked the complete requested prerequisite range through `d5a148ddbf3db595ea2faf0e6cefa19a8b0c79d0` before this correction. The local cherry-pick commits are `fba5351`, `1a9dfd5`, `df1a751`, `ac84c92`, `ee80677`, and `0e7025f`.

### Corrections applied

- `_includes/project-card.html` now has the required `<article class="card project-card">` root while preserving normalized-and-stripped URL assignments, guarded actions, the `h3` title, `tag-list`/`tag` stack markup, and `button button-secondary` action anchors.
- `_includes/post-card.html` now has the required `<article class="card post-card">` root and emits the exact required paragraph-wrapped date/time markup with `%Y 年 %m 月 %d 日`; its escaped summary, `h3` title, and tag list remain intact.
- `_layouts/post.html` now renders `← 返回博客` and uses `%Y 年 %m 月 %d 日`, while retaining the existing semantic article/header structure, `section`, `shell`, `prose`, and `section-heading` classes.
- `assets/css/main.scss` now defines only the missing planned action styles: `.button-row` and `.button-secondary` with the required declarations.

### Verification results

```text
$ python [exact Task 3 corrective contract check]
PASS: exact Task 3 correction contracts
Exit code 0

$ git diff --check
Exit code 0

$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

The focused static check asserts each exact required root/date/return-label/CSS selector string, plus retained URL guards, title heading levels, semantic layout classes, escaped post summary, and tag list markup.

### Concerns

- Ruby is not installed in this environment, so `ruby scripts/verify_site.rb` and the Jekyll build cannot run locally.
