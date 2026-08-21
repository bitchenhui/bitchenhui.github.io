# Task 2 Report — reusable site shell and theme controls

## Scope and changed files

Task 2 adds only the shared Jekyll presentation layer and updates the existing build verifier:

- `_includes/head.html` — encoding, viewport, SEO metadata, canonical and Atom links, CSS/JS assets, contextual title.
- `_includes/header.html` — Chinese brand/navigation controls, accessible mobile menu trigger, theme toggle.
- `_includes/footer.html` — year/author information and conditional email/GitHub/LinkedIn links.
- `_layouts/default.html` — semantic document shell, skip link, and shared partials.
- `assets/js/site.js` — local-storage/system-preference theme selection and safe menu/theme interactions.
- `assets/css/main.scss` — warm light and dark semantic token palettes, responsive layout, keyboard focus, mobile navigation, and reusable component classes.
- `scripts/verify_site.rb` — retains prior checks and now verifies the generated home page includes the navigation/theme IDs and stylesheet/script paths.

The prerequisite Task 1 configuration/assets were first cherry-picked as commit `5d36df1` (`chore: configure Jekyll site build`).

## RED evidence

1. Existing verifier before implementation:

```text
$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

Ruby is not installed in this environment, so the required generated-site verifier could not execute.

2. Focused failing pre-implementation shell check:

```text
AssertionError: Missing Task 2 shell assets: ['_includes/head.html', '_includes/header.html', '_includes/footer.html', '_layouts/default.html', 'assets/js/site.js', 'assets/css/main.scss']
Exit code 1
```

This failed for the intended reason: none of the Task 2 implementation files existed.

## GREEN evidence

1. Focused static requirements check after implementation:

```text
PASS: verified 7 Task 2 files and required static markers.
Exit code 0
```

It checks required Liquid markup, accessible-control attributes, theme/menu behavior markers, responsive component selectors, and the new verifier markers.

2. Whitespace validation:

```text
$ git diff --check
Exit code 0
```

3. JavaScript parser attempt:

```text
$ node --check assets/js/site.js
/usr/bin/bash: line 1: node: command not found
Exit code 127
```

Node.js is not installed, so an engine-level JavaScript syntax check could not run.

4. Updated generated-site verifier attempt:

```text
$ ruby scripts/verify_site.rb
/usr/bin/bash: line 1: ruby: command not found
Exit code 127
```

## Self-review

- All requested reusable shell files exist with UTF-8/document/mobile/SEO metadata and no public content pages were created.
- Theme behavior uses the stored `site-theme` value when present; otherwise it derives only the initial theme from the system dark preference. Toggle text, pressed state, accessible label, dataset, and persistence update together.
- Menu logic first checks both controls and only then binds behavior, so omitted controls do not cause an exception.
- CSS specifies both a 320px minimum and a 760px breakpoint with one-column cards and an explicitly opened mobile navigation class.
- Footer anchors are individually gated on nonempty author configuration. GitHub and LinkedIn have both `target="_blank"` and `rel="me noopener"`; no control uses an empty href.
- `scripts/verify_site.rb` retains all pre-existing checks and adds its required `index.html` assertions before the PASS output.

## Concerns

The requested Ruby/Jekyll build and verifier could not run because Ruby/Bundler are unavailable. JavaScript engine syntax validation also could not run because Node.js is unavailable. Static requirement validation and `git diff --check` did run successfully; generated output still needs verification in an environment with Ruby, Bundler, and the GitHub Pages Jekyll dependencies installed.
