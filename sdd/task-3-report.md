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
