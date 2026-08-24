# Single-Page Personal Manual Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the current multi-page Jekyll site into a single-page, résumé-like personal manual with a sticky profile card, structured experience/project/article sections, retained article detail routes, and compatible legacy URLs.

**Architecture:** Jekyll renders `/` from `_config.yml`, `_data/experience.yml`, `_data/projects.yml`, and `site.posts`. Focused Liquid includes render profile, experience, project, and article units; desktop CSS provides a bounded two-column layout and mobile CSS returns everything to normal document flow. `/projects/`, `/blog/`, and `/about/` become minimal static redirect pages, while `/blog/<slug>/`, RSS, sitemap, robots, and 404 remain first-class routes.

**Tech Stack:** GitHub Pages, Jekyll, Liquid, YAML, SCSS, vanilla JavaScript, Markdown, Ruby/Bundler, and the repository's dependency-free Ruby verifier.

## Global Constraints

- Preserve the current customized values in `_config.yml`: `dch个人空间`, `A video codecer who running to AGI`, `dch`, `主动拥抱AGI的视频编解码算法工程师`, `用AI重塑所有流程中；ACL努力康复中的篮球爱好者；北京探店`, `dch950301@163.com`, and the three existing skill strings.
- Do not invent companies, employment dates, education, clients, quantitative results, or other unverifiable claims; unknown experience fields must visibly say `TODO: 替换为……`.
- Keep `/` as the only primary content page; keep `/blog/<slug>/` article details.
- Keep `/projects/`, `/blog/`, and `/about/` only as minimal compatibility redirects to `/#projects`, `/#articles`, and `/#experience`.
- Add no frontend framework, application server, database, form, analytics, third-party tracking, third-party font, or new build system.
- Empty or whitespace-only contact and project URLs must not produce links.
- Desktop profile-card stickiness is an enhancement; mobile, text zoom, unsupported sticky positioning, and reduced-motion preferences must retain complete readable content.
- Delete obsolete, unreferenced presentation code and temporary `.superpowers/` files after implementation; do not delete compatibility redirect sources or article detail support.
- Actual `bundle exec jekyll build` and `ruby scripts/verify_site.rb` evidence is required before claiming completion. Static inspection is useful when Ruby is unavailable but is not a substitute.

## File Responsibility Map

**Create**

- `_data/experience.yml` — ordered, explicitly placeholder-marked experience records.
- `_includes/profile-card.html` — one reusable semantic profile/contact summary.
- `_includes/experience-item.html` — one experience record renderer.

**Modify**

- `_config.yml` — remove obsolete navigation, convert skills to capability objects, add current focus, and exclude development-only directories.
- `index.html` — compose the complete single-page document and all required anchors/empty states.
- `_includes/head.html` — support one canonical URL and optional static redirect metadata.
- `_includes/header.html` — retain only brand and theme control.
- `_includes/footer.html` — retain concise valid-only links.
- `_includes/project-card.html` — preserve valid-only external actions and add accessible external-link descriptions.
- `_includes/post-card.html` — add an explicit article-detail action.
- `_layouts/post.html` — return directly to `/#articles`.
- `assets/css/main.scss` — implement document hierarchy, two-column/sticky layout, cards, responsive fallback, and reduced motion; remove navigation-menu CSS.
- `assets/js/site.js` — retain theme behavior and remove all menu behavior.
- `projects/index.html`, `blog/index.html`, `about.md` — replace old duplicate content with minimal compatibility redirects.
- `scripts/verify_site.rb` — enforce the new source and generated-site contracts.
- `README.md` — document one-page content maintenance, experience data, article details, and compatibility routes.

**Retain**

- `Gemfile`, `_layouts/default.html`, `_layouts/page.html`, `_data/projects.yml`, `_posts/*.md`, `404.html`, and `robots.txt`.
- Plugin-generated `feed.xml` and `sitemap.xml`; do not create source files for them.

---

### Task 1: Lock the New Content Contract in Configuration and Data

**Files:**
- Modify: `_config.yml:15-44`
- Create: `_data/experience.yml`
- Modify: `scripts/verify_site.rb:20-35`

**Interfaces:**
- Produces: `site.current_focus` as `Array<String>`.
- Produces: `site.skills` as `Array<Hash>` with required `name` and `description` strings.
- Produces: `site.data.experience` as `Array<Hash>` with `period`, `role`, `summary`, and `highlights: Array<String>`.
- Consumes: the existing author fields without changing their values.

- [ ] **Step 1: Add failing source-contract assertions to the verifier**

Insert before the `_site` existence check in `scripts/verify_site.rb`:

```ruby
config = Pathname.new("_config.yml")
abort "FAIL: _config.yml is missing." unless config.file?
config_content = config.read

abort "FAIL: obsolete navigation configuration remains." if config_content.match?(/^navigation:/)
abort "FAIL: current focus is missing." unless config_content.match?(/^current_focus:/)
abort "FAIL: capability descriptions are missing." unless config_content.include?("description:")

experience_data = Pathname.new("_data/experience.yml")
abort "FAIL: experience data file is missing." unless experience_data.file?
experience_content = experience_data.read
%w[period role summary highlights].each do |field|
  abort "FAIL: experience data lacks #{field}." unless experience_content.match?(/^\s*#{field}:/)
end
abort "FAIL: experience placeholders are not explicit." unless experience_content.include?("TODO: 替换为")
```

Keep the existing project and README checks for now; later tasks replace their obsolete details.

- [ ] **Step 2: Run the verifier to confirm the new contract fails first**

Run:

```bash
ruby scripts/verify_site.rb
```

Expected: `FAIL: obsolete navigation configuration remains.` If `ruby` is unavailable, record that exact environment blocker and continue only with source inspection; do not call the test passed.

- [ ] **Step 3: Replace the obsolete configuration shape without changing personal values**

Remove `navigation:` and its four entries. Replace the current string list under `skills:` and add `current_focus:` as follows, leaving every existing site and `author` value unchanged:

```yaml
current_focus:
  - 用 AI 重塑视频编码算法研发流程
  - 视频编解码性能与质量优化
  - VOD / Live / RTC 场景体验优化

skills:
  - name: llm 的 EoH 算法自动迭代设计
    description: 探索 AI 驱动的算法生成、评估与持续迭代流程。
  - name: 视频编解码算法优化
    description: 聚焦 H.265、H.266、AV1 与 NVC 的编码效率和工程性能。
  - name: QoS / QoE 优化
    description: 面向 VOD、Live 与 RTC 场景分析并改善端到端体验。
```

Extend `exclude:` so development artifacts are not published:

```yaml
exclude:
  - Gemfile
  - Gemfile.lock
  - scripts
  - docs
  - sdd
  - .superpowers
  - .claude
```

- [ ] **Step 4: Create explicit placeholder experience data**

Create `_data/experience.yml`:

```yaml
- period: "TODO: 替换为时间范围"
  role: "TODO: 替换为职位 / 团队 / 工作场景"
  summary: "TODO: 替换为这段经历的职责和业务背景。"
  highlights:
    - "TODO: 替换为一项可公开、可验证的职责或成果。"
    - "TODO: 替换为另一项可公开、可验证的职责或成果。"
```

- [ ] **Step 5: Verify source syntax and contract progression**

Run:

```bash
ruby -e "require 'yaml'; YAML.safe_load_file('_config.yml', aliases: true); YAML.safe_load_file('_data/experience.yml', aliases: true); puts 'PASS: YAML parsed'"
ruby scripts/verify_site.rb
```

Expected first command: `PASS: YAML parsed`. Expected verifier result: it progresses beyond the new config/experience checks, then either reaches a later intentionally obsolete assertion or reports `_site` missing.

- [ ] **Step 6: Commit the content contract**

```bash
git add _config.yml _data/experience.yml scripts/verify_site.rb
git commit -m "feat: define single-page profile data"
```

---

### Task 2: Build Focused Resume Components

**Files:**
- Create: `_includes/profile-card.html`
- Create: `_includes/experience-item.html`
- Modify: `_includes/project-card.html:1-23`
- Modify: `_includes/post-card.html:1-12`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- `profile-card.html` consumes `site.author`, `site.current_focus`, and `site.skills`.
- `experience-item.html` consumes `include.item` with the Task 1 experience shape.
- `project-card.html` consumes `include.project` with existing project keys.
- `post-card.html` consumes a Jekyll post object and emits one explicit `阅读全文` link.

- [ ] **Step 1: Add failing component-source assertions**

Add before `_site` checks in `scripts/verify_site.rb`:

```ruby
required_includes = {
  "_includes/profile-card.html" => ["profile-card", "site.current_focus", "site.skills"],
  "_includes/experience-item.html" => ["experience-item", "include.item.highlights"],
  "_includes/post-card.html" => ["阅读全文", "include.post.url"],
  "_includes/project-card.html" => ["project_url", "repository_url"]
}.freeze

required_includes.each do |path, markers|
  file = Pathname.new(path)
  abort "FAIL: #{path} is missing." unless file.file?
  missing_markers = markers.reject { |marker| file.read.include?(marker) }
  abort "FAIL: #{path} lacks #{missing_markers.join(', ')}." unless missing_markers.empty?
end
```

- [ ] **Step 2: Run the verifier and confirm missing components fail**

Run `ruby scripts/verify_site.rb`.

Expected: `FAIL: _includes/profile-card.html is missing.`

- [ ] **Step 3: Create the profile card**

Create `_includes/profile-card.html` with one copy of the information used by both desktop and mobile layouts:

```liquid
{% assign email = site.author.email | default: "" | strip %}
{% assign github = site.author.github | default: "" | strip %}
{% assign linkedin = site.author.linkedin | default: "" | strip %}
{% assign resume_url = site.author.resume_url | default: "" | strip %}
<aside class="profile-card" aria-labelledby="profile-card-title">
  <p class="eyebrow">个人速览</p>
  <h2 id="profile-card-title">{{ site.author.name | escape }}</h2>
  <p class="profile-card__role">{{ site.author.role | escape }}</p>

  {% if site.current_focus and site.current_focus != empty %}
    <h3>当前关注</h3>
    <ul class="profile-card__list">
      {% for focus in site.current_focus %}<li>{{ focus | escape }}</li>{% endfor %}
    </ul>
  {% endif %}

  {% if site.skills and site.skills != empty %}
    <h3>核心能力</h3>
    <ul class="tag-list" aria-label="核心能力">
      {% for skill in site.skills %}<li class="tag">{{ skill.name | escape }}</li>{% endfor %}
    </ul>
  {% endif %}

  {% if email != "" or github != "" or linkedin != "" or resume_url != "" %}
    <h3>联系与资料</h3>
    <ul class="profile-card__links">
      {% if email != "" %}<li><a href="mailto:{{ email | escape }}">发送邮件</a></li>{% endif %}
      {% if github != "" %}<li><a href="{{ github | escape }}" target="_blank" rel="noopener noreferrer">GitHub（新窗口）</a></li>{% endif %}
      {% if linkedin != "" %}<li><a href="{{ linkedin | escape }}" target="_blank" rel="noopener noreferrer">LinkedIn（新窗口）</a></li>{% endif %}
      {% if resume_url != "" %}<li><a href="{{ resume_url | escape }}" target="_blank" rel="noopener noreferrer">查看简历（新窗口）</a></li>{% endif %}
    </ul>
  {% endif %}
</aside>
```

- [ ] **Step 4: Create the experience item**

Create `_includes/experience-item.html`:

```liquid
<article class="experience-item">
  <p class="experience-item__period">{{ include.item.period | escape }}</p>
  <div class="experience-item__body">
    <h3>{{ include.item.role | escape }}</h3>
    <p>{{ include.item.summary | escape }}</p>
    {% if include.item.highlights and include.item.highlights != empty %}
      <ul>
        {% for highlight in include.item.highlights %}<li>{{ highlight | escape }}</li>{% endfor %}
      </ul>
    {% endif %}
  </div>
</article>
```

- [ ] **Step 5: Finish project and article card actions**

Keep the current URL normalization and conditional action row in `_includes/project-card.html`, but change external anchors to `rel="noopener noreferrer"` and visible labels to `查看项目（新窗口）` / `查看代码（新窗口）`.

Replace `_includes/post-card.html` with:

```liquid
<article class="card post-card">
  <p class="card-meta"><time datetime="{{ include.post.date | date_to_xmlschema }}">{{ include.post.date | date: "%Y 年 %m 月 %d 日" }}</time></p>
  <h3><a href="{{ include.post.url | relative_url }}">{{ include.post.title | escape }}</a></h3>
  <p>{{ include.post.description | default: include.post.excerpt | strip_html | normalize_whitespace | escape }}</p>
  {% if include.post.tags and include.post.tags != empty %}
    <ul class="tag-list" aria-label="文章标签">
      {% for tag in include.post.tags %}<li class="tag">{{ tag | escape }}</li>{% endfor %}
    </ul>
  {% endif %}
  <p class="card-action"><a href="{{ include.post.url | relative_url }}">阅读全文<span aria-hidden="true"> →</span></a></p>
</article>
```

- [ ] **Step 6: Re-run source contract checks**

Run `ruby scripts/verify_site.rb`.

Expected: component checks pass; the verifier stops only at `_site` absence or a later not-yet-updated generated-page assertion.

- [ ] **Step 7: Commit components**

```bash
git add _includes/profile-card.html _includes/experience-item.html _includes/project-card.html _includes/post-card.html scripts/verify_site.rb
git commit -m "feat: add personal manual components"
```

---

### Task 3: Compose the Single-Page Information Architecture

**Files:**
- Modify: `index.html:1-52`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- Consumes all Task 1 data and Task 2 includes.
- Produces the stable anchors `#capabilities`, `#experience`, `#projects`, `#articles`, and `#contact`.
- Renders every project and post without `featured` filtering or limits.

- [ ] **Step 1: Replace obsolete homepage assertions with failing single-page assertions**

In `scripts/verify_site.rb`, replace the old hero/navigation markers with source checks:

```ruby
home_source = Pathname.new("index.html").read
required_home_markers = %w[
  id="capabilities"
  id="experience"
  id="projects"
  id="articles"
  id="contact"
  include\ profile-card.html
  include\ experience-item.html
  site.data.projects
  site.posts
]
missing_home_markers = required_home_markers.reject { |marker| home_source.include?(marker.tr("\\", "")) }
abort "FAIL: homepage source lacks #{missing_home_markers.join(', ')}." unless missing_home_markers.empty?
abort "FAIL: homepage still filters featured projects." if home_source.include?('where: "featured"')
abort "FAIL: homepage still limits primary content." if home_source.match?(/for (project|post).+limit:/)
```

- [ ] **Step 2: Confirm the old homepage fails the new contract**

Run `ruby scripts/verify_site.rb`.

Expected: `FAIL: homepage source lacks id="capabilities"...`.

- [ ] **Step 3: Replace `index.html` with the single-page composition**

Use this complete section structure; retain the existing front matter:

```liquid
---
layout: default
title: 首页
---
<div class="shell manual-layout">
  <section class="manual-hero" aria-labelledby="intro-title">
    <p class="eyebrow">PERSONAL MANUAL / 01</p>
    <h1 id="intro-title">{{ site.author.role | escape }}</h1>
    <p class="manual-hero__lead">{{ site.author.intro | escape }}</p>
    <nav class="anchor-nav" aria-label="本页内容">
      <a href="#capabilities">核心能力</a>
      <a href="#experience">工作经历</a>
      <a href="#projects">代表项目</a>
      <a href="#articles">技术文章</a>
      <a href="#contact">联系我</a>
    </nav>
  </section>

  <div class="manual-sidebar">{% include profile-card.html %}</div>

  <section id="capabilities" class="manual-section" aria-labelledby="capabilities-title">
    <p class="section-index">02 / CAPABILITIES</p>
    <h2 id="capabilities-title">核心能力</h2>
    <div class="capability-list">
      {% for skill in site.skills %}
        <article class="capability-item">
          <h3>{{ skill.name | escape }}</h3>
          <p>{{ skill.description | escape }}</p>
        </article>
      {% endfor %}
    </div>
  </section>

  <section id="experience" class="manual-section" aria-labelledby="experience-title">
    <p class="section-index">03 / EXPERIENCE</p>
    <h2 id="experience-title">工作经历</h2>
    {% if site.data.experience and site.data.experience != empty %}
      <div class="experience-list">
        {% for item in site.data.experience %}{% include experience-item.html item=item %}{% endfor %}
      </div>
    {% else %}
      <p class="empty-state">经历内容待补充。</p>
    {% endif %}
  </section>

  <section id="projects" class="manual-section" aria-labelledby="projects-title">
    <p class="section-index">04 / PROJECTS</p>
    <h2 id="projects-title">代表项目</h2>
    {% if site.data.projects and site.data.projects != empty %}
      <div class="card-grid">
        {% for project in site.data.projects %}{% include project-card.html project=project %}{% endfor %}
      </div>
    {% else %}
      <p class="empty-state">项目内容待补充。</p>
    {% endif %}
  </section>

  <section id="articles" class="manual-section" aria-labelledby="articles-title">
    <p class="section-index">05 / WRITING</p>
    <h2 id="articles-title">技术文章</h2>
    {% if site.posts.size > 0 %}
      <div class="card-grid">
        {% for post in site.posts %}{% include post-card.html post=post %}{% endfor %}
      </div>
    {% else %}
      <p class="empty-state">文章内容待更新。</p>
    {% endif %}
  </section>

  <section id="contact" class="manual-section contact-section" aria-labelledby="contact-title">
    <p class="section-index">06 / CONTACT</p>
    <h2 id="contact-title">联系我</h2>
    {% assign email = site.author.email | default: "" | strip %}
    {% if email != "" %}
      <p>如果你正在寻找视频编解码算法、AI 驱动研发流程或音视频体验优化方向的合作，可以通过 <a href="mailto:{{ email | escape }}">{{ email | escape }}</a> 联系我。</p>
    {% else %}
      <p class="empty-state">公开联系方式待补充。</p>
    {% endif %}
  </section>
</div>
```

The profile include is rendered exactly once. Because every section and `.manual-sidebar` is a direct grid child, desktop CSS can keep all content sections in column one and the sidebar in column two; on mobile, normal source order becomes hero → profile → capabilities → experience → projects → articles → contact without duplicate IDs or hidden duplicate content.

- [ ] **Step 4: Re-run source contract checks**

Run `ruby scripts/verify_site.rb`.

Expected: homepage source assertions pass and execution reaches `_site` or the next planned assertion.

- [ ] **Step 5: Commit the page architecture**

```bash
git add index.html scripts/verify_site.rb
git commit -m "feat: compose single-page personal manual"
```

---

### Task 4: Implement the Visual System, Sticky Sidebar, and Theme-Only Header

**Files:**
- Modify: `_includes/header.html:1-12`
- Modify: `_includes/footer.html:1-14`
- Modify: `assets/js/site.js:1-41`
- Modify: `assets/css/main.scss:87-212`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- Header produces `#theme-toggle`, but no `#mobile-menu-button` or `#primary-navigation`.
- JavaScript reads/writes `document.documentElement.dataset.theme` and `localStorage['site-theme']` only.
- CSS keeps `.manual-sidebar` sticky above `54rem` and returns the same element to normal document flow at or below `54rem`.

- [ ] **Step 1: Add failing removal and style assertions**

Add source assertions:

```ruby
header_source = Pathname.new("_includes/header.html").read
script_source = Pathname.new("assets/js/site.js").read
style_source = Pathname.new("assets/css/main.scss").read

abort "FAIL: header lacks theme control." unless header_source.include?('id="theme-toggle"')
%w[mobile-menu-button primary-navigation site.navigation].each do |obsolete|
  abort "FAIL: obsolete header marker remains: #{obsolete}." if header_source.include?(obsolete)
end
%w[menuButton navigation is-open].each do |obsolete|
  abort "FAIL: obsolete menu script remains: #{obsolete}." if script_source.include?(obsolete)
end
%w[manual-layout manual-sidebar profile-card position:\ sticky scroll-margin-top].each do |marker|
  abort "FAIL: stylesheet lacks #{marker}." unless style_source.include?(marker.tr("\\", ""))
end
```

- [ ] **Step 2: Confirm old navigation code fails**

Run `ruby scripts/verify_site.rb`.

Expected: `FAIL: obsolete header marker remains: mobile-menu-button.`

- [ ] **Step 3: Reduce the header and script**

Replace `_includes/header.html`:

```liquid
<div class="shell site-header__inner">
  <a class="site-brand" href="{{ '/' | relative_url }}">{{ site.title }}</a>
  <button id="theme-toggle" class="icon-button" type="button" aria-pressed="false" aria-label="切换深色模式">深色</button>
</div>
```

Replace `assets/js/site.js`:

```javascript
(function () {
  "use strict";

  var root = document.documentElement;
  var themeToggle = document.getElementById("theme-toggle");

  function updateThemeControl(theme) {
    if (!themeToggle) return;
    var isDark = theme === "dark";
    themeToggle.textContent = isDark ? "浅色" : "深色";
    themeToggle.setAttribute("aria-pressed", String(isDark));
    themeToggle.setAttribute("aria-label", isDark ? "切换为浅色模式" : "切换为深色模式");
  }

  function readStoredTheme() {
    try { return window.localStorage.getItem("site-theme"); } catch (error) { return null; }
  }

  function storeTheme(theme) {
    try { window.localStorage.setItem("site-theme", theme); } catch (error) { /* Theme still works for this page view. */ }
  }

  var storedTheme = readStoredTheme();
  var initialTheme = storedTheme || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  root.dataset.theme = initialTheme;
  updateThemeControl(initialTheme);

  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      root.dataset.theme = nextTheme;
      storeTheme(nextTheme);
      updateThemeControl(nextTheme);
    });
  }
}());
```

- [ ] **Step 4: Update footer links with the same normalized optional-field contract**

Normalize all optional author URLs with `default: "" | strip`; render only non-empty values. Add `resume_url`, use `rel="noopener noreferrer"` for external new-window links, and keep the footer text concise. Do not duplicate full profile content.

- [ ] **Step 5: Replace navigation CSS and add complete layout rules**

Keep existing tokens, global typography, focus, card primitives, footer, and reduced-motion rules. Remove `.primary-navigation`, `.mobile-menu-button`, and `html.js` menu rules. Set the header grid to `grid-template-columns: 1fr auto` and append:

```scss
[id] { scroll-margin-top: 6rem; }

.site-header__inner {
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: center;
  min-height: 4.5rem;
  gap: 1rem;
}

.manual-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(16rem, 20rem);
  align-items: start;
  column-gap: clamp(2rem, 5vw, 5rem);
  padding-block: clamp(2.5rem, 6vw, 5rem);
}
.manual-layout > :not(.manual-sidebar) { min-width: 0; grid-column: 1; }
.manual-hero { padding-bottom: clamp(3rem, 7vw, 6rem); }
.manual-hero__lead { max-width: var(--reading); color: var(--muted); font-size: 1.12rem; }
.eyebrow, .section-index, .card-meta { color: var(--muted); font-size: 0.78rem; font-weight: 750; letter-spacing: 0.12em; text-transform: uppercase; }
.anchor-nav { display: flex; flex-wrap: wrap; gap: 0.65rem 1.2rem; margin-top: 2rem; }
.anchor-nav a { font-weight: 700; }
.manual-section { padding-block: clamp(2.75rem, 6vw, 5rem); border-top: 1px solid var(--line); }
.manual-section > h2 { margin-bottom: 2rem; }
.manual-sidebar { position: sticky; top: 6rem; grid-column: 2; grid-row: 1 / span 7; }
.profile-card { padding: 1.4rem; border: 1px solid var(--line); border-radius: var(--radius); background: var(--surface); box-shadow: var(--shadow); }
.profile-card h2 { margin-bottom: 0.35rem; }
.profile-card h3 { margin-top: 1.5rem; font-size: 0.95rem; }
.profile-card__role { color: var(--muted); }
.profile-card__list, .profile-card__links { padding-left: 1.15rem; }
.capability-list, .experience-list { display: grid; gap: 1rem; }
.capability-item { padding: 1.3rem 0; border-bottom: 1px solid var(--line); }
.capability-item p { max-width: var(--reading); margin-bottom: 0; color: var(--muted); }
.experience-item { display: grid; grid-template-columns: minmax(8rem, 0.3fr) minmax(0, 1fr); gap: 1.5rem; padding: 1.5rem 0; border-top: 1px solid var(--line); }
.experience-item__period { color: var(--muted); font-size: 0.9rem; }
.card-action { margin-top: 1.25rem; font-weight: 700; }
.contact-section p { max-width: var(--reading); }

@media (max-width: 54rem) {
  .manual-layout { grid-template-columns: minmax(0, 1fr); }
  .manual-layout > :not(.manual-sidebar), .manual-sidebar { grid-column: 1; }
  .manual-sidebar { position: static; grid-row: 2; margin-bottom: 3rem; }
  .experience-item { grid-template-columns: 1fr; gap: 0.25rem; }
}

@media (max-width: 40rem) {
  .shell { width: min(calc(100% - 2rem), var(--shell)); }
  .card-grid { grid-template-columns: 1fr; }
  .site-footer__inner { align-items: flex-start; flex-direction: column; }
}
```

- [ ] **Step 6: Run source assertions and inspect for obsolete selectors**

Run:

```bash
ruby scripts/verify_site.rb
rg "primary-navigation|mobile-menu-button|menuButton|is-open" _includes assets index.html
```

Expected: verifier passes Task 4 source checks; `rg` prints no matches.

- [ ] **Step 7: Commit shell and visual behavior**

```bash
git add _includes/header.html _includes/footer.html assets/js/site.js assets/css/main.scss scripts/verify_site.rb
git commit -m "feat: add sticky resume layout"
```

---

### Task 5: Preserve Legacy URLs with Minimal Static Redirects

**Files:**
- Modify: `_includes/head.html:1-8`
- Modify: `projects/index.html:1-12`
- Modify: `blog/index.html:1-29`
- Modify: `about.md:1-31`
- Modify: `_layouts/post.html:1-22`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- Compatibility front matter provides `redirect_to` and `canonical_url` as root-relative strings with fragments.
- `head.html` emits exactly one canonical link and optional `http-equiv="refresh"`.
- Every redirect body contains a normal clickable fallback link.

- [ ] **Step 1: Add failing redirect-source assertions**

Add:

```ruby
redirect_sources = {
  "projects/index.html" => "/#projects",
  "blog/index.html" => "/#articles",
  "about.md" => "/#experience"
}.freeze
redirect_sources.each do |path, target|
  body = Pathname.new(path).read
  abort "FAIL: #{path} lacks redirect target #{target}." unless body.include?("redirect_to: #{target}")
  abort "FAIL: #{path} lacks canonical target #{target}." unless body.include?("canonical_url: #{target}")
  abort "FAIL: #{path} lacks a fallback link." unless body.include?("继续前往")
end
```

Also assert `_layouts/post.html` contains `/#articles` and no longer contains `href="{{ '/blog/'`.

- [ ] **Step 2: Confirm current route pages fail**

Run `ruby scripts/verify_site.rb`.

Expected: `FAIL: projects/index.html lacks redirect target /#projects.`

- [ ] **Step 3: Make head metadata redirect-aware**

Replace the canonical line in `_includes/head.html` and add refresh metadata:

```liquid
{% assign canonical_path = page.canonical_url | default: page.url %}
<link rel="canonical" href="{{ canonical_path | absolute_url }}">
{% if page.redirect_to %}
  <meta http-equiv="refresh" content="0; url={{ page.redirect_to | relative_url }}">
{% endif %}
```

Keep charset, viewport, description, feed, stylesheet, script, and title exactly once.

- [ ] **Step 4: Minimize all three compatibility pages**

Use this exact shape for `projects/index.html`, changing title/targets/text for each route:

```liquid
---
layout: page
title: 项目入口已合并
permalink: /projects/
redirect_to: /#projects
canonical_url: /#projects
---
<p>项目内容已合并到个人说明书首页。<a href="{{ '/#projects' | relative_url }}">继续前往项目板块</a>。</p>
```

For `blog/index.html`, use title `文章入口已合并`, both targets `/#articles`, and fallback text `继续前往文章板块`.

For `about.md`, use title `关于入口已合并`, both targets `/#experience`, and fallback text `继续前往经历板块`.

- [ ] **Step 5: Point article details directly back to the homepage section**

In `_layouts/post.html`, replace the `/blog/` return link with:

```liquid
<p><a href="{{ '/#articles' | relative_url }}">← 返回技术文章</a></p>
```

- [ ] **Step 6: Run source assertions**

Run `ruby scripts/verify_site.rb`.

Expected: redirect/post source checks pass and execution reaches generated-site checks.

- [ ] **Step 7: Commit compatibility routing**

```bash
git add _includes/head.html projects/index.html blog/index.html about.md _layouts/post.html scripts/verify_site.rb
git commit -m "feat: preserve legacy section routes"
```

---

### Task 6: Rewrite Generated-Site Verification Around the Approved Design

**Files:**
- Modify: `scripts/verify_site.rb:5-81`

**Interfaces:**
- Requires the same eleven generated files currently listed.
- Verifies source contracts before requiring `_site`.
- Verifies generated homepage anchors/content, article routes, redirect metadata/fallbacks, discovery files, language, viewport, and non-empty links.

- [ ] **Step 1: Add generated-output expectations before rebuilding**

Replace obsolete generated-home/blog checks with:

```ruby
home = (SITE / "index.html").read
required_home_markers = %w[
  id="theme-toggle"
  id="capabilities"
  id="experience"
  id="projects"
  id="articles"
  id="contact"
  class="profile-card"
  /assets/css/main.css
  /assets/js/site.js
]
missing_markers = required_home_markers.reject { |marker| home.include?(marker) }
abort "FAIL: generated homepage lacks #{missing_markers.join(', ')}." unless missing_markers.empty?
%w[primary-navigation mobile-menu-button].each do |obsolete|
  abort "FAIL: generated homepage retains #{obsolete}." if home.include?(obsolete)
end

project_titles = projects_content.scan(/^\s*- title:\s*["']?([^"'\n]+)["']?/).flatten
missing_projects = project_titles.reject { |title| home.include?(title.strip) }
abort "FAIL: homepage omits projects: #{missing_projects.join(', ')}" unless missing_projects.empty?

post_titles = Pathname.glob("_posts/*").map do |post|
  post.read[/^title:\s*["']?([^"'\n]+)["']?/, 1]
end.compact
missing_posts = post_titles.reject { |title| home.include?(title.strip) }
abort "FAIL: homepage omits posts: #{missing_posts.join(', ')}" unless missing_posts.empty?
```

Add generated redirect checks:

```ruby
redirect_outputs = {
  "projects/index.html" => "/#projects",
  "blog/index.html" => "/#articles",
  "about/index.html" => "/#experience"
}.freeze
redirect_outputs.each do |path, target|
  body = (SITE / path).read
  abort "FAIL: #{path} lacks refresh target." unless body.include?("http-equiv=\"refresh\"") && body.include?(target)
  abort "FAIL: #{path} lacks canonical target." unless body.include?("rel=\"canonical\"") && body.include?(target)
  abort "FAIL: #{path} lacks clickable fallback." unless body.include?("继续前往")
end
```

Retain checks for `lang="zh-CN"`, viewport, empty `href`, 404 home link, Atom feed, robots sitemap directive, sitemap canonical URL, and all article detail outputs.

- [ ] **Step 2: Run the verifier against the stale or absent build**

Run `ruby scripts/verify_site.rb`.

Expected before rebuild: `_site` missing or a generated homepage marker failure. This proves the verifier distinguishes old output from the target site.

- [ ] **Step 3: Build and run the complete verifier**

Run:

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected:

```text
Configuration file: .../_config.yml
...
PASS: verified <N> HTML file(s) and 11 required site file(s).
```

If Ruby/Bundler/Jekyll is unavailable, stop this task as blocked. Do not edit assertions merely to avoid the environment requirement.

- [ ] **Step 4: Check generated links and stale navigation directly**

Run:

```bash
rg 'href=["'"']\s*["'"']' _site
rg 'primary-navigation|mobile-menu-button|查看全部项目|查看全部文章' _site
```

Expected: both commands produce no matches.

- [ ] **Step 5: Commit final verifier behavior**

```bash
git add scripts/verify_site.rb
git commit -m "test: verify single-page site contract"
```

---

### Task 7: Update Maintainer Documentation

**Files:**
- Modify: `README.md:1-97`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- README documents `_config.yml`, `_data/experience.yml`, `_data/projects.yml`, `_posts/`, route behavior, preview/build commands, deployment, and domain setup.

- [ ] **Step 1: Expand README section assertions first**

Set the verifier's required README sections to:

```ruby
required_readme_sections = %w[
  单页结构
  配置个人信息
  添加经历
  添加项目
  写文章
  兼容入口
  本地预览
  发布到GitHubPages
  独立域名
]
normalized_readme = readme_content.gsub(/\s+/, "")
missing_readme_sections = required_readme_sections.reject { |section| normalized_readme.include?(section) }
```

- [ ] **Step 2: Confirm README contract fails**

Run `ruby scripts/verify_site.rb`.

Expected: failure listing at least `单页结构`, `添加经历`, and `兼容入口`.

- [ ] **Step 3: Rewrite README maintenance guidance**

Retain the existing exact preview/build/deploy/domain commands and security warning. Add these concrete facts:

```markdown
## 单页结构

首页 `/` 是唯一主要内容入口，依次展示个人定位、核心能力、经历、项目、技术文章和联系方式。文章详情继续使用 `/blog/<slug>/`；`/projects/`、`/blog/`、`/about/` 仅用于把旧链接引导到首页对应板块。

## 添加经历

在 `_data/experience.yml` 中按展示顺序添加条目：

```yaml
- period: "真实时间范围"
  role: "真实职位 / 团队 / 工作场景"
  summary: "职责和业务背景"
  highlights:
    - "可公开、可验证的职责或成果"
```

未确认的信息继续使用 `TODO: 替换为……`，不要发布虚构履历或量化成果。

## 兼容入口

`/projects/`、`/blog/` 和 `/about/` 是最小兼容跳转页，不维护重复内容。项目与全部文章卡片直接维护在首页的数据源中；文章正文仍由 `_posts/` 生成独立详情页。
```

Update project guidance to state every project appears on the homepage and `featured` is retained only for existing-data compatibility. Update skill guidance for the new `name` / `description` object shape and `current_focus` list.

- [ ] **Step 4: Verify documentation and full site**

Run:

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected: both pass.

- [ ] **Step 5: Commit documentation**

```bash
git add README.md scripts/verify_site.rb
git commit -m "docs: explain single-page site maintenance"
```

---

### Task 8: Audit References, Delete Unused Artifacts, and Perform Final Acceptance

**Files:**
- Delete: `.superpowers/` (untracked visual-companion runtime data)
- Delete: only tracked presentation files proven to have no references and no route/build responsibility
- Modify: any file where the audit exposes stale selectors or references

**Interfaces:**
- Preserves all files listed under **Retain** and all three compatibility redirect sources.
- Leaves no obsolete menu implementation or duplicate multi-page content.

- [ ] **Step 1: Build a reference inventory before deleting anything**

Run:

```bash
rg "include |layout:|site\.data|assets/(css|js)|primary-navigation|mobile-menu-button|featured_projects|查看全部" --glob '!_site/**' --glob '!.git/**' .
git status --short
```

Expected: all runtime includes/layouts/assets have a current consumer; no old navigation, menu, featured filtering, or “查看全部” UI references remain. Inspect every candidate before deletion.

- [ ] **Step 2: Remove known temporary output and only proven-dead files/code**

Delete `.superpowers/`. Remove obsolete code blocks found by Step 1. Do **not** delete:

- `projects/index.html`, `blog/index.html`, `about.md` (compatibility routes);
- `_layouts/page.html` (404 and compatibility pages);
- `_layouts/post.html` or `_includes/post-card.html` (article details/home cards);
- `404.html`, `robots.txt`, posts, data, or plugin configuration.

Use repository-aware removal for tracked dead files:

```bash
rm -rf .superpowers
git rm <only-paths-proven-dead-by-reference-audit>
```

If no tracked file is dead, omit `git rm`; deleting obsolete sections inside retained files satisfies the cleanup requirement.

- [ ] **Step 3: Run formatting, source, and generated-site verification**

Run:

```bash
git diff --check
bundle exec jekyll build
ruby scripts/verify_site.rb
rg "primary-navigation|mobile-menu-button|menuButton|featured_projects|查看全部项目|查看全部文章" --glob '!_site/**' --glob '!docs/**' .
git status --short
```

Expected: `git diff --check`, build, and verifier pass; `rg` produces no runtime matches; status lists only intended implementation changes and no `.superpowers/`.

- [ ] **Step 4: Launch the site and perform desktop acceptance**

Run:

```bash
bundle exec jekyll serve
```

At `http://127.0.0.1:4000/`, verify at a desktop viewport:

1. Only brand and theme toggle appear in the header.
2. All five anchors reach the correct sections without headings hiding under the sticky header.
3. The sidebar profile card remains visible while the main content scrolls, stays within its grid column, and does not cover the footer.
4. Every project and every article appears; cards with blank external URLs have no action row.
5. Article cards open retained detail routes, and detail pages return directly to `/#articles`.
6. Light/dark switching updates label and `aria-pressed`, survives reload, and still works when storage access is unavailable.
7. `/projects/`, `/blog/`, and `/about/` redirect to the correct homepage fragments and expose fallback links if refresh is disabled.

- [ ] **Step 5: Perform mobile, zoom, keyboard, and motion acceptance**

At 320px and 375px widths and at 200% text zoom, verify:

1. There is no horizontal scrolling.
2. Exactly one profile card is visible and it is in normal document flow.
3. Experience items and cards collapse to one readable column.
4. All controls are reachable by keyboard and have a visible focus indicator.
5. Skip link reaches `#main-content`.
6. With reduced motion enabled, anchor scrolling is not animated and transitions are effectively disabled.

Any failure returns to the owning task; rerun build and verifier after fixing it.

- [ ] **Step 6: Commit cleanup and acceptance fixes**

```bash
git add -A
git commit -m "chore: remove obsolete site artifacts"
```

If Step 2 produced no tracked change and acceptance required no fix, do not create an empty commit.

- [ ] **Step 7: Record final evidence before declaring completion**

Run:

```bash
git status --short
git log --oneline --max-count=8
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected: clean status except deliberately untracked user-owned files, implementation commits visible, build succeeds, and verifier prints its PASS summary. Report any skipped browser scenario or unavailable tool explicitly instead of claiming full completion.
