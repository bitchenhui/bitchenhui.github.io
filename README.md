# bitchenhui.github.io

这是一个使用 **Jekyll** 构建、由 **GitHub Pages** 从仓库发布的中文个人网站。网站保持原生 Jekyll 结构：不需要额外前端框架、应用服务器、数据库或 GitHub Actions。

> **安全提醒：先完成所有 `TODO: 替换为…` 的个人信息，再公开发布。** 示例中的姓名、定位、项目描述和链接并不代表真实经历；请勿把它们当作可对外声明的内容。

## 单页结构

首页 `/` 是唯一主要内容入口，依次展示个人定位、核心能力、经历、项目（个人作品）和联系方式。`/projects/`、`/blog/`、`/about/` 仅用于把旧链接引导到首页对应板块。当前版本定位为线上简历，技术文章板块暂未开放；`_layouts/post.html`、`_includes/post-card.html` 与 `_posts/` 已移除，未来恢复写作时再按 Jekyll 惯例重建。

首页带有一组「码流美学」交互：标题以宏块马赛克逐步解码入场；鼠标划过 Hero 区会点亮宏块并显示运动矢量；右上角 `HiFi / 240p` 按钮模拟低码率画质（去圆角、像素化、扫描线），偏好与主题一样保存在浏览器本地。所有效果尊重 `prefers-reduced-motion`，仅用原生 Canvas 实现，不引入外部依赖。

## 本地预览

请先安装 Ruby 3.1 或更高版本以及 Bundler，并在仓库根目录执行：

```bash
bundle install
bundle exec jekyll serve
```

随后在浏览器访问 <http://127.0.0.1:4000>。预览进程运行时会监听本地文件变更，按 `Ctrl+C` 可停止服务。

要生成静态文件并运行仓库检查，请执行：

```bash
bundle exec jekyll build
ruby scripts/verify_site.rb
```

生成结果位于 `_site/`，不需要提交该目录。

## 配置个人信息

编辑根目录的 `_config.yml`，将以下带有 `TODO: 替换为…` 的字段替换为自己的信息：

- `title`、`description`：网站名称和一句中文个人定位；
- `url`、`baseurl`：实际部署地址与站点子路径；个人 GitHub Pages 通常保持 `baseurl: ""`；
- `author.name`、`author.role`、`author.intro`：姓名、角色和简介；
- `author.email`、`author.github`、`author.linkedin`、`author.resume_url`：可公开的联系和资料链接；`resume_url` 可选——把 PDF 简历放入 `assets/` 后填 `/assets/resume.pdf`，留空则网站只展示在线简历页 `/resume/`；
- `current_focus`：当前重点方向的字符串列表；
- `skills`：核心能力对象列表，每项包含 `name` 和 `description`。

```yaml
current_focus:
  - "当前重点方向"

skills:
  - name: "能力名称"
    description: "能力说明"
```

发布前再次检查所有页面、`_data/experience.yml` 和 `_data/projects.yml` 是否仍有示例性 `TODO`，并只填写可以公开、能够佐证的真实信息。

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

## 添加项目

项目数据集中在 `_data/projects.yml`，定位是**个人作品 / 开源项目**——公司里的工作成果写在 `_data/experience.yml` 的 highlights 中即可，不要两边重复。为每个项目新增一段 YAML，并填写这些字段：

```yaml
- title: "项目名称"
  period: "时间范围（可选）"
  description: "项目的真实用途、职责或成果说明"
  highlights:
    - "可公开、可验证的量化成果（可选）"
  stack:
    - 技术或工具 1
    - 技术或工具 2
  cover: "/assets/img/项目封面.png（可选）"
  project_url: "https://example.com/project"
  repository_url: "https://github.com/your-name/project"
```

`title`、`description` 和 `stack` 用于展示项目内容；`period`、`highlights`、`cover` 为可选字段，分别展示时间范围、量化成果列表和项目封面图（封面图放入 `assets/img/`）。每个项目都会按数据顺序出现在首页，并同步汇总到简历页 `/resume/` 的「项目经历」。`project_url` 与 `repository_url` 是可选字段。只有在对应 URL 非空时，项目卡片才会分别显示“查看项目”或“查看代码”链接；没有真实可公开链接时请保留为空，避免生成无效链接。不要用未经确认的成果、客户或数据填充项目描述。

## 写文章（暂未开放）

当前版本为线上简历定位，文章板块已移除，本章节仅保留未来恢复时的约定：文章存放于 `_posts/`，文件名必须采用 `YYYY-MM-DD-article-slug.md` 格式，使用 Markdown 和 YAML front matter（`layout: post`、`title`、`date`、`description`、`tags`），永久链接规则为 `/blog/:title/`。恢复前需重建 `_layouts/post.html` 与 `_includes/post-card.html`，并同步更新 `scripts/verify_site.rb`。

## 简历页

`/resume/` 是页面版简历，数据完全复用 `_config.yml`、`_data/experience.yml` 和 `_data/projects.yml`——更新这些数据源后简历页自动同步，无需单独维护。页面提供「打印 / 导出 PDF」按钮（打印样式会自动隐藏导航和页脚）；如需挂 PDF 版简历，把文件放入 `assets/` 并在 `_config.yml` 的 `author.resume_url` 填入路径。`_data/experience.yml` 中的 `org`（公司/团队）与 `_data/projects.yml` 中的 `period`、`highlights`、`cover` 均为可选字段。

## SEO 与分享

站点在 `_includes/head.html` 中内置 Open Graph / Twitter Card 分享元信息、SVG favicon（`assets/img/favicon.svg`）与首页 Person 结构化数据（JSON-LD）。页面标题与描述分别来自各页 front matter 的 `title`、`description`，新增页面时建议填写 `description` 以获得更好的分享摘要。

## 兼容入口

`/projects/`、`/blog/` 和 `/about/` 是最小兼容跳转页，不维护重复内容。项目内容直接维护在首页的数据源中；`/blog/` 因文章板块下线而跳转回首页。

## 发布到 GitHub Pages

1. 完成内容替换及本地检查后，检查改动：`git status`。
2. 提交并推送到 `main`：`git add .`、`git commit -m "你的提交说明"`、`git push origin main`。
3. 在 GitHub 仓库中打开 **Settings → Pages**。
4. 将 Source 设为 **Deploy from a branch**，分支设为 **main**，目录设为 **/(root)**，然后保存。
5. 等待 Pages 部署完成后，访问准确站点地址：<https://bitchenhui.github.io/>。

GitHub Pages 会从该分支的根目录构建 Jekyll 网站，不需要 GitHub Actions。

## 独立域名

只有在已经实际注册并可以管理某个域名后，才执行以下步骤：

1. 在 GitHub 仓库的 **Settings → Pages → Custom domain** 中填写实际域名，例如 `www.example.com`，并保存。
2. 在域名 DNS 控制台添加推荐记录：为 `www` 添加指向 `bitchenhui.github.io` 的 `CNAME`；若使用根域名 `example.com`，按 GitHub Pages 文档添加指向 GitHub Pages IP 地址的 `A` 记录（可同时配置 `www` 的 `CNAME`）。
3. 等待 DNS 生效，并确认 GitHub Pages 中的自定义域名状态没有错误。
4. 仅在 DNS 和实际域名均已确认后，在根目录创建 `CNAME` 文件；文件内容只能是实际选择的域名，例如 `www.example.com`。
5. 在 Pages 设置中启用 **Enforce HTTPS**；证书签发前该选项可能暂不可用，应等待后再开启。
6. 重新访问自定义域名及原始 GitHub Pages 地址，运行本地构建与 `ruby scripts/verify_site.rb`，并确认站内链接、重定向和 HTTPS 都正常。

> **不要在拥有并配置真实域名之前创建 `CNAME` 文件。** 目前仓库不应包含预设 `CNAME`，也不应添加 `.nojekyll`；后者会跳过 GitHub Pages 的 Jekyll 处理，破坏本站的原生构建流程。
