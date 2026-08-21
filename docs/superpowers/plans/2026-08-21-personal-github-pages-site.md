# Personal GitHub Pages Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish a Chinese-first, technology-minimal personal website with projects, Markdown blog posts, résumé content, RSS, responsive layout, and accessible light/dark themes on GitHub Pages.

**Architecture:** Jekyll renders Liquid templates, Markdown pages, post front matter, and YAML project data into a static site. Reusable includes provide the document head, navigation, footer, project cards, and post cards; layouts compose these into pages and articles. A single SCSS theme and small vanilla-JavaScript controller handle responsive presentation, menu state, and persisted theme preference.

**Tech Stack:** GitHub Pages, Jekyll, Liquid, SCSS, vanilla JavaScript, YAML, Markdown, Ruby/Bundler (`github-pages` gem), and a Ruby static-build verification script.

## Global Constraints

- Use GitHub Pages’ native Jekyll build and deployment; do not add a frontend framework, application server, database, GitHub Actions workflow, or `.nojekyll` file.
- Present site chrome and sample content in Simplified Chinese; retain technical names and code syntax in their original language.
- Default to a warm, nearly white technology-minimal visual system with one low-saturation blue-violet accent; dark mode is manual and optional, not the default presentation.
- Provide a keyboard-accessible manual theme toggle; follow the operating-system theme only when the visitor has not stored a preference in `localStorage`.
- Render no control with a blank `href`; hide optional project/social controls whose configured URL is blank.
- Use semantic HTML, visible focus treatment, meaningful `alt` text for non-decorative images, and a responsive layout that remains usable at 320 px width.
- Store real-person placeholders only as explicit `TODO: 替换为…` configuration/content text. Do not claim sample experience, employment, projects, or contact addresses are real.
- Do not add a `CNAME` file until a real custom domain is chosen.

---

## File Structure

| Path | Responsibility |
|---|---|
| `Gemfile` | Pins the local Jekyll/GitHub Pages preview environment. |
| `_config.yml` | Site identity, author/contact placeholders, permalink, plugins, and build settings. |
| `_data/projects.yml` | Structured project portfolio records consumed by home and project pages. |
| `_includes/head.html` | Metadata, canonical URL, RSS discovery, stylesheet, and JavaScript references. |
| `_includes/header.html` | Accessible fixed site navigation, mobile menu button, and theme switch. |
| `_includes/footer.html` | Contact and social link rendering with empty-link suppression. |
| `_includes/project-card.html` | Semantic project-card presentation from one YAML record. |
| `_includes/post-card.html` | Article card presentation with description fallback. |
| `_layouts/default.html` | Document shell and shared site chrome. |
| `_layouts/page.html` | Standard page content container. |
| `_layouts/post.html` | Article metadata, tags, and prose container. |
| `assets/css/main.scss` | Design tokens, global elements, components, responsive rules, dark palette. |
| `assets/js/site.js` | Theme initialization/persistence and accessible mobile menu control. |
| `index.html` | Home sections: hero, skills, featured projects, recent posts. |
| `projects/index.html` | Full project portfolio page. |
| `blog/index.html` | Blog listing, including an empty state. |
| `about.md` | Resume/biography content with clearly marked placeholders. |
| `_posts/*.md` | Three sample Markdown articles and their metadata. |
| `404.html` | Friendly not-found page. |
| `robots.txt` | Search crawler policy and sitemap discovery. |
| `scripts/verify_site.rb` | Dependency-free static checks over generated `_site` files. |
| `README.md` | Setup, preview, authoring, deployment, and custom-domain operating guide. |

## Task 1: Establish the local Jekyll build and test harness

**Files:**
- Create: `Gemfile`
- Create: `_config.yml`
- Create: `scripts/verify_site.rb`
- Modify: `README.md`

**Interfaces:**
- Consumes: the repository root and GitHub Pages’ default deployment branch (`main`).
- Produces: `bundle exec jekyll build`, which writes `_site/`; `ruby scripts/verify_site.rb`, which exits zero only when required generated paths and document properties exist.

- [ ] **Step 1: Write the failing static-build verification script**

Create `scripts/verify_site.rb` with a required-file list before any site pages exist:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

SITE = Pathname.new("_site")
REQUIRED_FILES = %w[
  index.html
  projects/index.html
  blog/index.html
  about/index.html
  404.html
  feed.xml
  sitemap.xml
  robots.txt
].freeze

abort "FAIL: _site does not exist; run `bundle exec jekyll build` first." unless SITE.directory?

missing = REQUIRED_FILES.reject { |path| (SITE / path).file? }
abort "FAIL: missing generated files: #{missing.join(', ')}" unless missing.empty?

html_files = SITE.glob("**/*.html")
abort "FAIL: no generated HTML pages found." if html_files.empty?

html_files.each do |file|
  body = file.read
  abort "FAIL: #{file} has no lang=\"zh-CN\" document language." unless body.include?("lang=\"zh-CN\"")
  abort "FAIL: #{file} has no viewport metadata." unless body.include?("name=\"viewport\"")
  abort "FAIL: #{file} contains an empty href attribute." if body.match?(/href=[\"']\s*[\"']/)
end

puts "PASS: verified #{html_files.length} HTML file(s) and #{REQUIRED_FILES.length} required site file(s)."
```

- [ ] **Step 2: Run the verifier to prove it fails before implementation**

Run:

```bash
ruby scripts/verify_site.rb
```

Expected: process exits non-zero with `FAIL: _site does not exist` because the Jekyll configuration and generated site do not exist yet.

- [ ] **Step 3: Add the Jekyll/GitHub Pages local build contract**

Create `Gemfile`:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
```

Create `_config.yml`:

```yaml
title: "TODO: 替换为你的网站名称"
description: "TODO: 替换为一句中文个人定位"
url: "https://bitchenhui.github.io"
baseurl: ""
lang: "zh-CN"
timezone: "Asia/Shanghai"
permalink: /blog/:title/
markdown: kramdown
highlighter: rouge
plugins:
  - jekyll-feed
  - jekyll-sitemap

collections: {}

navigation:
  - title: 首页
    url: /
  - title: 项目
    url: /projects/
  - title: 博客
    url: /blog/
  - title: 关于
    url: /about/

author:
  name: "TODO: 替换为你的姓名"
  role: "TODO: 替换为你的个人定位"
  intro: "TODO: 用两三句话介绍你的技术方向、兴趣与正在做的事情。"
  email: ""
  github: ""
  linkedin: ""
  resume_url: ""

skills:
  - 性能优化
  - 系统工程
  - 技术写作

exclude:
  - Gemfile
  - Gemfile.lock
  - scripts
  - docs
```

- [ ] **Step 4: Document reproducible local setup**

Replace `README.md` with this initial operational guide; later tasks extend its authoring and domain sections:

```markdown
# bitchenhui.github.io

使用 Jekyll 构建、由 GitHub Pages 发布的个人网站。

## 本地预览

前提：安装 Ruby 3.1 或更高版本与 Bundler。

```bash
bundle install
bundle exec jekyll serve
```

浏览器访问 `http://127.0.0.1:4000`。停止预览后可用 `Ctrl+C` 退出。

## 构建检查

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Jekyll 的生成目录为 `_site/`，无需提交该目录。

## 发布

提交并推送到 `main` 分支。仓库的 GitHub Pages 设置选择 **Deploy from a branch**，分支选择 `main`、目录选择 `/(root)`；GitHub Pages 会自动构建并发布。
```

- [ ] **Step 5: Install dependencies and prove the configuration builds**

Run:

```bash
bundle install
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected: the Jekyll command succeeds, but the verifier fails with a message listing missing generated page files. This proves the harness is active and that the next tasks must create each public endpoint.

- [ ] **Step 6: Commit the build foundation**

```bash
git add Gemfile _config.yml scripts/verify_site.rb README.md
git commit -m "chore: configure Jekyll site build"
```

## Task 2: Build reusable document shell, navigation, theme controls, and responsive design system

**Files:**
- Create: `_includes/head.html`
- Create: `_includes/header.html`
- Create: `_includes/footer.html`
- Create: `_layouts/default.html`
- Create: `assets/css/main.scss`
- Create: `assets/js/site.js`

**Interfaces:**
- Consumes: `site.title`, `site.description`, `site.url`, `site.baseurl`, `site.lang`, `site.navigation`, and `site.author` from `_config.yml`.
- Produces: a `default` layout that every later page can declare; `#primary-navigation`, `#mobile-menu-button`, and `#theme-toggle` identifiers consumed by `assets/js/site.js`.

- [ ] **Step 1: Add a failing theme/navigation assertion to the verifier**

Immediately before the final `puts` in `scripts/verify_site.rb`, add:

```ruby
home = (SITE / "index.html").read
abort "FAIL: home page lacks accessible primary navigation." unless home.include?("id=\"primary-navigation\"")
abort "FAIL: home page lacks a theme toggle." unless home.include?("id=\"theme-toggle\"")
abort "FAIL: home page does not load the site stylesheet." unless home.include?("/assets/css/main.css")
abort "FAIL: home page does not load the site controller." unless home.include?("/assets/js/site.js")
```

- [ ] **Step 2: Run the build and verifier to prove the new assertion fails**

Run:

```bash
bundle exec jekyll build && ruby scripts/verify_site.rb
```

Expected: failure due to missing public HTML pages; once a temporary home exists later, the exact assertion will fail until this shell is connected. Do not weaken or remove the assertion.

- [ ] **Step 3: Create the shared HTML includes and default layout**

Create `_includes/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="{{ page.description | default: site.description | escape }}">
<link rel="canonical" href="{{ page.url | absolute_url }}">
<link rel="alternate" type="application/atom+xml" title="{{ site.title | escape }}" href="{{ '/feed.xml' | relative_url }}">
<link rel="stylesheet" href="{{ '/assets/css/main.css' | relative_url }}">
<script src="{{ '/assets/js/site.js' | relative_url }}" defer></script>
<title>{% if page.title %}{{ page.title | escape }} · {% endif %}{{ site.title | escape }}</title>
```

Create `_includes/header.html`:

```html
<header class="site-header">
  <div class="shell header-inner">
    <a class="site-brand" href="{{ '/' | relative_url }}" aria-label="返回首页">{{ site.title }}</a>
    <button id="mobile-menu-button" class="icon-button menu-button" type="button" aria-expanded="false" aria-controls="primary-navigation">
      菜单
    </button>
    <nav id="primary-navigation" class="primary-navigation" aria-label="主导航">
      <ul>
        {% for item in site.navigation %}
          <li><a href="{{ item.url | relative_url }}"{% if page.url == item.url %} aria-current="page"{% endif %}>{{ item.title }}</a></li>
        {% endfor %}
      </ul>
    </nav>
    <button id="theme-toggle" class="icon-button" type="button" aria-pressed="false" aria-label="切换深色模式">深色</button>
  </div>
</header>
```

Create `_includes/footer.html`:

```html
<footer class="site-footer">
  <div class="shell footer-inner">
    <p>© {{ 'now' | date: '%Y' }} {{ site.author.name }} · 使用 Jekyll 与 GitHub Pages 构建</p>
    <ul class="social-links" aria-label="联系与社交链接">
      {% if site.author.email != "" %}<li><a href="mailto:{{ site.author.email }}">邮箱</a></li>{% endif %}
      {% if site.author.github != "" %}<li><a href="{{ site.author.github }}" rel="me noopener" target="_blank">GitHub</a></li>{% endif %}
      {% if site.author.linkedin != "" %}<li><a href="{{ site.author.linkedin }}" rel="me noopener" target="_blank">LinkedIn</a></li>{% endif %}
    </ul>
  </div>
</footer>
```

Create `_layouts/default.html`:

```html
<!doctype html>
<html lang="{{ site.lang }}">
  <head>{% include head.html %}</head>
  <body>
    <a class="skip-link" href="#main-content">跳到主要内容</a>
    {% include header.html %}
    <main id="main-content">{{ content }}</main>
    {% include footer.html %}
  </body>
</html>
```

- [ ] **Step 4: Implement the theme controller**

Create `assets/js/site.js`:

```javascript
(() => {
  const storageKey = "site-theme";
  const root = document.documentElement;
  const themeToggle = document.querySelector("#theme-toggle");
  const menuButton = document.querySelector("#mobile-menu-button");
  const navigation = document.querySelector("#primary-navigation");

  const preferredTheme = () => window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  const applyTheme = (theme) => {
    root.dataset.theme = theme;
    if (themeToggle) {
      const isDark = theme === "dark";
      themeToggle.setAttribute("aria-pressed", String(isDark));
      themeToggle.textContent = isDark ? "浅色" : "深色";
      themeToggle.setAttribute("aria-label", isDark ? "切换浅色模式" : "切换深色模式");
    }
  };

  applyTheme(localStorage.getItem(storageKey) || preferredTheme());

  themeToggle?.addEventListener("click", () => {
    const nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
    localStorage.setItem(storageKey, nextTheme);
    applyTheme(nextTheme);
  });

  menuButton?.addEventListener("click", () => {
    const isOpen = menuButton.getAttribute("aria-expanded") === "true";
    menuButton.setAttribute("aria-expanded", String(!isOpen));
    navigation?.classList.toggle("is-open", !isOpen);
  });
})();
```

- [ ] **Step 5: Implement the focused visual system**

Create `assets/css/main.scss`:

```scss
---
---
:root {
  --bg: #f7f8fa;
  --surface: #ffffff;
  --text: #171a24;
  --muted: #5f6676;
  --line: #dbe0e8;
  --accent: #575dd7;
  --accent-soft: #eceeff;
  --shadow: 0 16px 40px rgb(32 42 70 / 8%);
  --radius: 18px;
  color-scheme: light;
}

:root[data-theme="dark"] {
  --bg: #10121a;
  --surface: #181b26;
  --text: #f0f2f8;
  --muted: #b3bacb;
  --line: #30364a;
  --accent: #aeb2ff;
  --accent-soft: #282c50;
  --shadow: 0 16px 40px rgb(0 0 0 / 28%);
  color-scheme: dark;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  min-width: 320px;
  background: var(--bg);
  color: var(--text);
  font-family: Inter, "PingFang SC", "Microsoft YaHei", system-ui, sans-serif;
  line-height: 1.7;
}
a { color: var(--accent); text-underline-offset: 0.18em; }
a:hover { text-decoration-thickness: 0.14em; }
a:focus-visible, button:focus-visible { outline: 3px solid var(--accent); outline-offset: 3px; }
button { font: inherit; }
.shell { width: min(1120px, calc(100% - 40px)); margin-inline: auto; }
.skip-link { position: fixed; left: 1rem; top: -5rem; z-index: 5; padding: 0.6rem 0.9rem; background: var(--text); color: var(--bg); }
.skip-link:focus { top: 1rem; }
.site-header { position: sticky; top: 0; z-index: 2; border-bottom: 1px solid var(--line); background: color-mix(in srgb, var(--bg) 90%, transparent); backdrop-filter: blur(14px); }
.header-inner, .footer-inner { display: flex; align-items: center; gap: 1rem; min-height: 4.5rem; }
.site-brand { color: var(--text); font-weight: 750; text-decoration: none; letter-spacing: -0.03em; }
.primary-navigation { margin-left: auto; }
.primary-navigation ul, .social-links { display: flex; gap: 1rem; margin: 0; padding: 0; list-style: none; }
.primary-navigation a { color: var(--muted); text-decoration: none; }
.primary-navigation a[aria-current="page"], .primary-navigation a:hover { color: var(--text); }
.icon-button { border: 1px solid var(--line); border-radius: 999px; padding: 0.4rem 0.7rem; background: var(--surface); color: var(--text); cursor: pointer; }
.menu-button { display: none; }
.site-footer { margin-top: 5rem; border-top: 1px solid var(--line); color: var(--muted); font-size: 0.9rem; }
.site-footer p { margin: 0; }
.section { padding: 4.5rem 0; }
.section-heading { margin: 0 0 0.75rem; font-size: clamp(1.6rem, 4vw, 2.4rem); line-height: 1.2; letter-spacing: -0.04em; }
.section-lead { max-width: 65ch; margin: 0; color: var(--muted); }
.card-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.25rem; margin-top: 2rem; }
.card { height: 100%; padding: 1.5rem; border: 1px solid var(--line); border-radius: var(--radius); background: var(--surface); box-shadow: var(--shadow); }
.card h3 { margin-top: 0; line-height: 1.3; }
.card p { color: var(--muted); }
.tag-list { display: flex; flex-wrap: wrap; gap: 0.45rem; margin: 1rem 0; padding: 0; list-style: none; }
.tag { padding: 0.16rem 0.55rem; border-radius: 999px; background: var(--accent-soft); color: var(--accent); font-size: 0.8rem; }
.button-row { display: flex; flex-wrap: wrap; gap: 0.8rem; margin-top: 1.5rem; }
.button { display: inline-block; padding: 0.65rem 1rem; border: 1px solid var(--accent); border-radius: 999px; background: var(--accent); color: #fff; text-decoration: none; }
.button-secondary { background: transparent; color: var(--accent); }
.prose { width: min(760px, 100%); }
.prose img { max-width: 100%; height: auto; border-radius: 12px; }
.empty-state { padding: 2rem; border: 1px dashed var(--line); border-radius: var(--radius); color: var(--muted); }

@media (max-width: 760px) {
  .shell { width: min(100% - 32px, 1120px); }
  .header-inner { flex-wrap: wrap; }
  .menu-button { display: inline-block; margin-left: auto; }
  .primary-navigation { display: none; width: 100%; order: 4; margin-left: 0; }
  .primary-navigation.is-open { display: block; }
  .primary-navigation ul { flex-direction: column; padding: 0.5rem 0 1rem; }
  .card-grid { grid-template-columns: 1fr; }
  .footer-inner { align-items: flex-start; flex-direction: column; padding-block: 1.25rem; }
}
```

- [ ] **Step 6: Build the completed shell and inspect its generated assets**

Run:

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected: build succeeds; verifier still fails only because public pages do not exist yet. Confirm that `_site/assets/css/main.css` and `_site/assets/js/site.js` exist with:

```bash
ruby -e 'abort "FAIL: missing CSS" unless File.file?("_site/assets/css/main.css"); abort "FAIL: missing JS" unless File.file?("_site/assets/js/site.js"); puts "PASS: theme assets generated"'
```

Expected: `PASS: theme assets generated`.

- [ ] **Step 7: Commit reusable chrome and theme behavior**

```bash
git add _includes _layouts assets scripts/verify_site.rb
git commit -m "feat: add responsive site shell and theme toggle"
```

## Task 3: Add portfolio data and reusable project/post presentation

**Files:**
- Create: `_data/projects.yml`
- Create: `_includes/project-card.html`
- Create: `_includes/post-card.html`
- Create: `_layouts/page.html`
- Create: `_layouts/post.html`

**Interfaces:**
- Consumes: `site.data.projects`; an include argument named `project`; an include argument named `post`.
- Produces: `{% include project-card.html project=project %}` and `{% include post-card.html post=post %}` for use in the home, projects, and blog pages; `page` and `post` layouts for front matter.

- [ ] **Step 1: Add a failing portfolio-data assertion**

Add this block to `scripts/verify_site.rb` before the final `puts`:

```ruby
projects_data = Pathname.new("_data/projects.yml")
abort "FAIL: project data file is missing." unless projects_data.file?
project_data = projects_data.read
abort "FAIL: project data has no featured item." unless project_data.include?("featured: true")
abort "FAIL: project data has no explicit placeholder marker." unless project_data.include?("TODO: 替换为")
```

- [ ] **Step 2: Run the verifier to prove it fails**

Run:

```bash
ruby scripts/verify_site.rb
```

Expected: non-zero exit. Once `_site` is generated, it must specifically report `FAIL: project data file is missing.`

- [ ] **Step 3: Define example project data without presenting it as real work**

Create `_data/projects.yml`:

```yaml
- title: "视频编码优化工具"
  description: "TODO: 替换为真实项目。示例：面向编码性能定位、实验记录和参数比较的工具集合。"
  stack: [C++, Python, 性能分析]
  featured: true
  project_url: ""
  repository_url: ""

- title: "性能分析平台"
  description: "TODO: 替换为真实项目。示例：将基准测试、关键指标和回归结果统一展示的内部平台。"
  stack: [数据处理, 可视化, 自动化]
  featured: true
  project_url: ""
  repository_url: ""

- title: "个人开源工具"
  description: "TODO: 替换为真实项目。示例：为日常开发流程减少重复操作的轻量命令行工具。"
  stack: [开源, CLI, 工程效率]
  featured: true
  project_url: ""
  repository_url: ""
```

- [ ] **Step 4: Create card includes and page/article layouts**

Create `_includes/project-card.html`:

```html
<article class="card project-card">
  <h3>{{ include.project.title | escape }}</h3>
  <p>{{ include.project.description | escape }}</p>
  {% if include.project.stack and include.project.stack.size > 0 %}
    <ul class="tag-list" aria-label="技术栈">
      {% for item in include.project.stack %}<li class="tag">{{ item }}</li>{% endfor %}
    </ul>
  {% endif %}
  {% if include.project.project_url != "" or include.project.repository_url != "" %}
    <div class="button-row">
      {% if include.project.project_url != "" %}<a class="button button-secondary" href="{{ include.project.project_url }}" target="_blank" rel="noopener">查看项目</a>{% endif %}
      {% if include.project.repository_url != "" %}<a class="button button-secondary" href="{{ include.project.repository_url }}" target="_blank" rel="noopener">查看代码</a>{% endif %}
    </div>
  {% endif %}
</article>
```

Create `_includes/post-card.html`:

```html
<article class="card post-card">
  <p><time datetime="{{ include.post.date | date_to_xmlschema }}">{{ include.post.date | date: "%Y 年 %m 月 %d 日" }}</time></p>
  <h3><a href="{{ include.post.url | relative_url }}">{{ include.post.title | escape }}</a></h3>
  <p>{{ include.post.description | default: include.post.excerpt | strip_html | normalize_whitespace | escape }}</p>
  {% if include.post.tags and include.post.tags.size > 0 %}
    <ul class="tag-list" aria-label="文章标签">
      {% for tag in include.post.tags %}<li class="tag">{{ tag }}</li>{% endfor %}
    </ul>
  {% endif %}
</article>
```

Create `_layouts/page.html`:

```html
---
layout: default
---
<section class="section">
  <div class="shell prose">
    <h1 class="section-heading">{{ page.title | escape }}</h1>
    {{ content }}
  </div>
</section>
```

Create `_layouts/post.html`:

```html
---
layout: default
---
<article class="section">
  <div class="shell prose">
    <p><a href="{{ '/blog/' | relative_url }}">← 返回博客</a></p>
    <p><time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: "%Y 年 %m 月 %d 日" }}</time></p>
    <h1 class="section-heading">{{ page.title | escape }}</h1>
    {% if page.tags and page.tags.size > 0 %}
      <ul class="tag-list" aria-label="文章标签">
        {% for tag in page.tags %}<li class="tag">{{ tag }}</li>{% endfor %}
      </ul>
    {% endif %}
    {{ content }}
  </div>
</article>
```

- [ ] **Step 5: Run the verifier and confirm the data test passes**

Run:

```bash
bundle exec jekyll build && ruby scripts/verify_site.rb
```

Expected: the project-data assertions pass. The overall verifier still fails only due to required generated HTML endpoints not yet created.

- [ ] **Step 6: Commit the content model**

```bash
git add _data _includes/project-card.html _includes/post-card.html _layouts/page.html _layouts/post.html scripts/verify_site.rb
git commit -m "feat: add portfolio data and content layouts"
```

## Task 4: Implement the public content pages and sample Markdown posts

**Files:**
- Create: `index.html`
- Create: `projects/index.html`
- Create: `blog/index.html`
- Create: `about.md`
- Create: `_posts/2026-08-21-encoding-performance.md`
- Create: `_posts/2026-08-22-engineering-practice.md`
- Create: `_posts/2026-08-23-toolchain-notes.md`

**Interfaces:**
- Consumes: layouts and includes from Tasks 2–3, `site.author`, `site.skills`, `site.data.projects`, and `site.posts`.
- Produces: all primary navigation targets plus three generated post pages using `/blog/:title/` permalinks.

- [ ] **Step 1: Expand verifier requirements for content-generated pages**

Replace the `REQUIRED_FILES` array in `scripts/verify_site.rb` with:

```ruby
REQUIRED_FILES = %w[
  index.html
  projects/index.html
  blog/index.html
  about/index.html
  blog/encoding-performance/index.html
  blog/engineering-practice/index.html
  blog/toolchain-notes/index.html
  404.html
  feed.xml
  sitemap.xml
  robots.txt
].freeze
```

Then add:

```ruby
abort "FAIL: home page lacks the hero heading." unless home.include?("个人网站首版示例")
abort "FAIL: blog index lacks its empty-state fallback." unless (SITE / "blog/index.html").read.include?("暂时还没有文章")
```

- [ ] **Step 2: Run the build and prove endpoint verification fails**

Run:

```bash
bundle exec jekyll build && ruby scripts/verify_site.rb
```

Expected: non-zero exit and a list containing `index.html`, `projects/index.html`, `blog/index.html`, `about/index.html`, and the three post page paths.

- [ ] **Step 3: Build the home, projects, blog, and about pages**

Create `index.html`:

```html
---
layout: default
title: 首页
---
<section class="section hero">
  <div class="shell">
    <p class="tag">PERSONAL SITE / 01</p>
    <h1 class="section-heading">个人网站首版示例<br>TODO: 替换为你的个人定位</h1>
    <p class="section-lead">{{ site.author.intro }}</p>
    <div class="button-row">
      <a class="button" href="{{ '/projects/' | relative_url }}">查看项目</a>
      <a class="button button-secondary" href="{{ '/blog/' | relative_url }}">阅读博客</a>
    </div>
  </div>
</section>

<section class="section">
  <div class="shell">
    <h2 class="section-heading">关注的方向</h2>
    <ul class="tag-list" aria-label="技能与方向">
      {% for skill in site.skills %}<li class="tag">{{ skill }}</li>{% endfor %}
    </ul>
  </div>
</section>

<section class="section">
  <div class="shell">
    <h2 class="section-heading">精选项目</h2>
    <p class="section-lead">这些内容均为待替换的结构示例，用于说明作品集的呈现方式。</p>
    <div class="card-grid">
      {% assign featured_projects = site.data.projects | where: "featured", true %}
      {% for project in featured_projects limit: 3 %}{% include project-card.html project=project %}{% endfor %}
    </div>
    <p><a href="{{ '/projects/' | relative_url }}">查看全部项目 →</a></p>
  </div>
</section>

<section class="section">
  <div class="shell">
    <h2 class="section-heading">最新文章</h2>
    <div class="card-grid">
      {% for post in site.posts limit: 3 %}{% include post-card.html post=post %}{% endfor %}
    </div>
    <p><a href="{{ '/blog/' | relative_url }}">查看全部文章 →</a></p>
  </div>
</section>
```

Create `projects/index.html`:

```html
---
layout: page
title: 项目
permalink: /projects/
---
<p class="section-lead">以下为项目展示结构示例。发布前请将说明、链接和技术栈替换为真实内容。</p>
<div class="card-grid">
  {% for project in site.data.projects %}{% include project-card.html project=project %}{% endfor %}
</div>
```

Create `blog/index.html`:

```html
---
layout: page
title: 博客
permalink: /blog/
---
<p class="section-lead">记录工程实践、性能思考与工具链探索。</p>
{% if site.posts.size > 0 %}
  <div class="card-grid">
    {% for post in site.posts %}{% include post-card.html post=post %}{% endfor %}
  </div>
{% else %}
  <p class="empty-state">暂时还没有文章。请在 <code>_posts/</code> 中新增一篇 Markdown 文章。</p>
{% endif %}
```

Create `about.md`:

```markdown
---
layout: page
title: 关于
permalink: /about/
---

## 简介

TODO: 替换为你的真实介绍。这里适合用一段简洁文字说明你关注的问题、擅长的方向和希望与访客交流的话题。

## 技能与方向

- TODO: 替换为核心技术栈或专业能力
- TODO: 替换为代表性工程经验
- TODO: 替换为正在探索的主题

## 经历

### TODO: 替换为职位 / 团队名称

TODO: 替换为时间范围与一至两项可公开描述的成果。

## 教育

TODO: 替换为学校、专业与时间信息。

## 联系方式

{% if site.author.email != "" %}可通过 [邮箱](mailto:{{ site.author.email }}) 联系。{% else %}TODO: 在 `_config.yml` 的 `author.email` 填写公开联系邮箱。{% endif %}

{% if site.author.resume_url != "" %}[下载简历]({{ site.author.resume_url }}){% else %}TODO: 如需提供简历，请在 `_config.yml` 的 `author.resume_url` 填写公开 PDF 链接。{% endif %}
```

- [ ] **Step 4: Add three illustrative Markdown articles**

Create `_posts/2026-08-21-encoding-performance.md`:

```markdown
---
layout: post
title: 编码性能分析：先建立可复现的基线
slug: encoding-performance
description: "示例文章：讨论性能优化开始前，如何定义输入、指标与可比较的实验环境。"
tags: [性能优化, 编码, 实验]
---

> TODO: 这是一篇结构示例。请替换为可公开发布的真实技术内容。

性能问题通常不是从“改一处代码”开始，而是从一条可重复的基线开始。固定输入、编译选项、机器负载和统计口径，才能让一次实验回答一个明确问题。

## 建立基线

1. 固定输入集与编码参数。
2. 同时记录耗时、吞吐、内存与质量指标。
3. 对同一版本重复运行，排除偶然波动。

## 记录结论

将假设、修改、结果与回退条件写入实验记录。这样即使优化没有收益，也会成为下一次定位的有效信息。
```

Create `_posts/2026-08-22-engineering-practice.md`:

```markdown
---
layout: post
title: 工程实践：让复杂改动保持可验证
slug: engineering-practice
description: "示例文章：以小范围提交、自动检查和可回退设计降低工程变更成本。"
tags: [工程实践, 测试, 协作]
---

> TODO: 这是一篇结构示例。请替换为可公开发布的真实技术内容。

复杂系统的改动并不一定要以复杂的发布过程收尾。将目标拆成可独立验证的小步骤，可以缩短反馈周期，也让回退更明确。

## 一个可验证的循环

- 先写出失败条件或验收检查。
- 只实现让检查通过的最小变更。
- 保留命令、输入和输出，方便其他人重现。

这种节奏并不降低开发速度，而是避免把不确定性积累到最后。
```

Create `_posts/2026-08-23-toolchain-notes.md`:

```markdown
---
layout: post
title: 工具链笔记：把重复操作变成可靠流程
slug: toolchain-notes
description: "示例文章：介绍如何从重复命令中识别值得自动化的步骤。"
tags: [工具链, 自动化, 效率]
---

> TODO: 这是一篇结构示例。请替换为可公开发布的真实技术内容。

一个值得自动化的步骤，通常有三个特征：频繁发生、输入规则稳定、失败后容易判断。先把这些步骤写成小脚本，再考虑是否需要更复杂的平台。

## 自动化的边界

自动化应输出足够的信息来解释自己做了什么。对于可能影响发布或数据的操作，应保留显式确认，而不是默默执行。
```

- [ ] **Step 5: Build every content route and run verifier**

Run:

```bash
bundle exec jekyll build && ruby scripts/verify_site.rb
```

Expected: success except for `404.html`, `feed.xml`, `sitemap.xml`, and `robots.txt`. Task 5 creates `404.html` and `robots.txt`; the configured `jekyll-feed` and `jekyll-sitemap` plugins generate the feed and sitemap. Confirm that generated post URLs follow the configured `/blog/:title/` pattern.

- [ ] **Step 6: Commit content pages and posts**

```bash
git add index.html projects/index.html blog/index.html about.md _posts scripts/verify_site.rb
git commit -m "feat: add portfolio blog and about pages"
```

## Task 5: Add discovery pages, error page, and crawler policy

**Files:**
- Create: `404.html`
- Create: `robots.txt`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- Consumes: `site.url`, `site.baseurl`, and `site.posts`; the `jekyll-feed` and `jekyll-sitemap` plugins configured in Task 1.
- Produces: valid `/404.html`, `/feed.xml`, `/robots.txt`, `/sitemap.xml` endpoints and a fully passing static verifier. The configured plugins generate `/feed.xml` and `/sitemap.xml`; do not create source files at either path.

- [ ] **Step 1: Add failing semantic endpoint tests**

Add before the final `puts` in `scripts/verify_site.rb`:

```ruby
not_found = (SITE / "404.html").read
abort "FAIL: 404 page does not link visitors home." unless not_found.include?("返回首页")

feed = (SITE / "feed.xml").read
abort "FAIL: generated feed is not Atom XML." unless feed.include?("<feed") && feed.include?("application/atom+xml")

robots = (SITE / "robots.txt").read
abort "FAIL: robots.txt does not advertise the sitemap." unless robots.include?("Sitemap:")

sitemap = (SITE / "sitemap.xml").read
abort "FAIL: generated sitemap lacks the home URL." unless sitemap.include?("https://bitchenhui.github.io/")
```

- [ ] **Step 2: Run the verification cycle and confirm failure**

Run:

```bash
bundle exec jekyll build && ruby scripts/verify_site.rb
```

Expected: fail because `404.html` and `robots.txt` are not generated yet. The `jekyll-feed` and `jekyll-sitemap` plugins should already generate `feed.xml` and `sitemap.xml`.

- [ ] **Step 3: Create the discovery and fallback source endpoints**

Create `404.html`:

```html
---
layout: page
title: 页面未找到
permalink: /404.html
---
<p class="section-lead">你访问的地址不存在，或内容已经移动。</p>
<p><a class="button" href="{{ '/' | relative_url }}">返回首页</a></p>
```

Create `robots.txt`:

```text
User-agent: *
Allow: /

Sitemap: https://bitchenhui.github.io/sitemap.xml
```

- [ ] **Step 4: Run the complete build verification**

Run:

```bash
rm -rf _site
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Expected: `PASS: verified 8 HTML file(s) and 11 required site file(s).` (The exact HTML count may be higher if the Jekyll version emits extra pages; the command must exit zero.)

- [ ] **Step 5: Commit reliability and discoverability endpoints**

```bash
git add 404.html robots.txt scripts/verify_site.rb
git commit -m "feat: add feed sitemap and not-found page"
```

## Task 6: Complete operating documentation and perform cross-viewport release verification

**Files:**
- Modify: `README.md`
- Modify: `scripts/verify_site.rb`

**Interfaces:**
- Consumes: final Jekyll source tree and generated `_site/` output.
- Produces: a maintenance guide that lets a future author configure identity, add content, deploy, and bind a domain; a final verifier that enforces all specified static guarantees.

- [ ] **Step 1: Add a failing README coverage test**

Add before the final `puts` in `scripts/verify_site.rb`:

```ruby
readme = Pathname.new("README.md")
abort "FAIL: README.md is missing." unless readme.file?
readme_text = readme.read
%w[本地预览 写文章 添加项目 独立域名].each do |section|
  abort "FAIL: README is missing the #{section} section." unless readme_text.include?(section)
end
```

- [ ] **Step 2: Run the verifier to show documentation is incomplete**

Run:

```bash
ruby scripts/verify_site.rb
```

Expected: non-zero exit with `FAIL: README is missing the 写文章 section.`

- [ ] **Step 3: Replace README with complete author and deployment instructions**

Replace `README.md` with:

```markdown
# bitchenhui.github.io

一个中文优先、浅色科技极简风格的 Jekyll 个人网站，由 GitHub Pages 发布。

## 本地预览

前提：安装 Ruby 3.1 或更高版本与 Bundler。

```bash
bundle install
bundle exec jekyll serve
```

浏览器访问 `http://127.0.0.1:4000`。停止预览后可用 `Ctrl+C` 退出。

## 构建检查

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

Jekyll 输出目录为 `_site/`，不需要提交此目录。

## 替换个人资料

编辑 `_config.yml`：

- `title`：站点名称。
- `description`：一句个人定位。
- `author.name`、`author.role`、`author.intro`：首页与页脚使用的个人信息。
- `author.email`、`author.github`、`author.linkedin`：填写后才会显示对应联系链接。
- `author.resume_url`：填写公开 PDF 地址后，关于页会显示简历下载链接。

保留 `TODO: 替换为…` 标记，直到你拥有可公开发布的真实资料；不要把示例项目与示例文章当作真实经历发布。

## 添加项目

编辑 `_data/projects.yml`，每个项目使用以下字段：

```yaml
- title: "项目名称"
  description: "项目的公开说明"
  stack: [技术栈一, 技术栈二]
  featured: true
  project_url: "https://example.com"
  repository_url: "https://github.com/example/project"
```

`featured: true` 的项目会出现在首页。`project_url` 或 `repository_url` 留空时，对应按钮不会显示。

## 写文章

在 `_posts/` 新建 Markdown 文件，文件名必须使用 `YYYY-MM-DD-slug.md` 形式，例如：

```markdown
---
layout: post
title: 文章标题
slug: article-slug
description: "文章摘要"
tags: [标签一, 标签二]
---

从这里开始写正文。
```

文章会自动出现在博客列表、首页最新文章和 `/feed.xml`。站点地址遵循 `/blog/article-slug/`。

## 发布到 GitHub Pages

提交并推送到 `main` 分支：

```bash
git add .
git commit -m "content: update personal site"
git push origin main
```

在 GitHub 仓库的 **Settings → Pages** 中选择 **Deploy from a branch**，然后选择 `main` 和 `/(root)`。发布地址为 `https://bitchenhui.github.io/`。

## 独立域名

当你已经购买并确定真实域名后：

1. 在 GitHub 仓库的 **Settings → Pages → Custom domain** 填写该域名。
2. 按 GitHub Pages 页面显示的 DNS 提示，在域名服务商处添加推荐的 `A`、`AAAA` 或 `CNAME` 记录。
3. DNS 生效后，在仓库根目录创建 `CNAME` 文件，内容仅为你的域名，例如 `www.example.com`。
4. 在 GitHub Pages 中开启 **Enforce HTTPS**。
5. 再次访问网站并确认 HTTPS、首页、RSS 和所有链接正常。

不要在拥有真实域名之前提交 `CNAME`；不要用 `.nojekyll`，否则 Jekyll 不会构建本网站。
```

- [ ] **Step 4: Perform final automated verification**

Run:

```bash
rm -rf _site
bundle exec jekyll build
ruby scripts/verify_site.rb
git diff --check
```

Expected: the verifier exits zero with `PASS: verified ...`; `git diff --check` prints no whitespace errors.

- [ ] **Step 5: Perform manual responsive and accessibility smoke checks**

Run the preview server:

```bash
bundle exec jekyll serve --livereload
```

Open `http://127.0.0.1:4000` and verify each condition in browser developer tools before stopping the server:

1. At 1440 px, header, hero, three-card project/article grids, footer, links, and both theme palettes are readable and visually aligned.
2. At 375 px and 320 px, the menu button opens/closes the nav, cards are one column, no horizontal scrollbar appears, and tap targets remain usable.
3. Keyboard navigation starts with the skip link, reaches each navigation item and the theme button, and shows a visible focus outline.
4. Toggle the theme button twice; refresh after each state and confirm the selected theme persists.
5. Visit `/projects/`, `/blog/`, `/about/`, each `/blog/<slug>/`, `/feed.xml`, `/sitemap.xml`, `/robots.txt`, and a nonexistent URL to confirm the 404 page and all endpoints work.

Stop the preview server with `Ctrl+C` after completing the checks.

- [ ] **Step 6: Commit the operating guide and final checks**

```bash
git add README.md scripts/verify_site.rb
git commit -m "docs: add personal site maintenance guide"
```

- [ ] **Step 7: Confirm the repository is ready for publishing**

Run:

```bash
git status --short
git log --oneline -6
```

Expected: `git status --short` prints nothing; the log contains the six focused commits produced by this plan, plus the pre-existing design/spec commits.

## Spec Coverage Self-Review

- **Jekyll / GitHub Pages native deployment:** Tasks 1 and 6 configure `github-pages`, document branch publishing, and do not create Actions or `.nojekyll`.
- **Homepage, projects, blog, résumé / about:** Task 4 creates all first-class routes and home sections.
- **Markdown articles, tags, summaries, article pages, RSS:** Tasks 3–5 establish post cards, layouts, sample posts, fallback summary, and plugin-generated Atom RSS.
- **Centralized personal/project configuration:** Tasks 1 and 3 define `_config.yml` and `_data/projects.yml`.
- **Light technology-minimal visual system plus dark toggle:** Task 2 defines CSS tokens, responsive components, OS fallback, explicit toggle, and `localStorage` persistence.
- **Responsive navigation and mobile layout:** Task 2 builds the accessible menu; Task 6 verifies 375 px and 320 px behavior.
- **Accessibility / empty controls / placeholders:** Tasks 2–4 use semantic markup, focus styles, skip link, conditional links, and explicit placeholders; Task 1’s verifier rejects empty `href`s.
- **404, robots, sitemap, custom-domain guidance:** Tasks 5–6 create endpoints and complete domain instructions without a premature `CNAME`.
- **Build / route / documentation verification:** Every task has a failing check first; Task 6 runs final automated and manual release checks.

Placeholder scan completed: the plan contains no unspecified implementation steps. Required placeholder text only appears as deliberate user-facing `TODO: 替换为…` content mandated by the approved design.
