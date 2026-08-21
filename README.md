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
