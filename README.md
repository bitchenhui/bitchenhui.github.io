# bitchenhui.github.io

这是一个使用 **Jekyll** 构建、由 **GitHub Pages** 从仓库发布的中文个人网站。网站保持原生 Jekyll 结构：不需要额外前端框架、应用服务器、数据库或 GitHub Actions。

> **安全提醒：先完成所有 `TODO: 替换为…` 的个人信息，再公开发布。** 示例中的姓名、定位、项目描述和链接并不代表真实经历；请勿把它们当作可对外声明的内容。

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
- `author.email`、`author.github`、`author.linkedin`、`author.resume_url`：可公开的联系和资料链接；
- `skills`：希望展示的技术方向。

发布前再次检查所有页面和 `_data/projects.yml` 是否仍有示例性 `TODO`，并只填写可以公开、能够佐证的真实信息。

## 添加项目

项目数据集中在 `_data/projects.yml`。为每个项目新增一段 YAML，并填写这些字段：

```yaml
- title: "项目名称"
  description: "项目的真实用途、职责或成果说明"
  stack:
    - 技术或工具 1
    - 技术或工具 2
  featured: true
  project_url: "https://example.com/project"
  repository_url: "https://github.com/your-name/project"
```

`title`、`description`、`stack` 和 `featured` 用于展示项目内容；`project_url` 与 `repository_url` 是可选字段。只有在对应 URL 非空时，项目卡片才会分别显示“查看项目”或“查看代码”链接；没有真实可公开链接时请保留为空，避免生成无效链接。不要用未经确认的成果、客户或数据填充项目描述。

## 写文章

文章存放在 `_posts/`，文件名必须采用 `YYYY-MM-DD-article-slug.md` 格式。新文章使用 Markdown 和 YAML front matter，例如：

```markdown
---
layout: post
title: "文章标题"
date: 2026-08-21 10:00:00 +0800
description: "一段简短的文章摘要"
tags:
  - Jekyll
  - 工程实践
---

这里开始写正文。可使用标准 Markdown 标题、列表、链接和代码块。
```

仓库配置的永久链接规则为 `/blog/:title/`，因此文件 `_posts/2026-08-21-article-slug.md` 发布后对应地址是 `/blog/article-slug/`。保存文章后运行本地预览或构建检查，确认 front matter、链接和 Markdown 渲染正常。

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
4. 在 Pages 设置中启用 **Enforce HTTPS**；证书签发前该选项可能暂不可用，应等待后再开启。
5. 重新访问自定义域名及原始 GitHub Pages 地址，运行本地构建与 `ruby scripts/verify_site.rb`，并确认站内链接、重定向和 HTTPS 都正常。

> **不要在拥有并配置真实域名之前创建 `CNAME` 文件。** 目前仓库不应包含预设 `CNAME`，也不应添加 `.nojekyll`；后者会跳过 GitHub Pages 的 Jekyll 处理，破坏本站的原生构建流程。
