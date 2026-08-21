# 最终审查修复报告

## 范围

本次仅修复最终审查提出的六项问题，并按顺序 cherry-pick 了从 `60182ae` 到 `4b0a687` 的 14 个父提交；过程中没有发生冲突。

## 修复内容

1. `scripts/verify_site.rb` 现在从源文件 `blog/index.html` 校验“暂时还没有文章”空状态，并在生成的 `_site/blog/index.html` 校验已渲染文章标题“编码性能分析：先建立可复现的基线”。
2. 两篇样例文章文件分别重命名为 `2026-08-20-engineering-practice.md` 与 `2026-08-19-toolchain-notes.md`；文件内容、front matter、slug 及 `/blog/:title/` 路由契约保持不变。
3. 博客页在文章卡片列表后增加“文章归档”语义 section，使用 `site.posts` 输出中文日期和文章链接。
4. 默认布局的主内容区域增加 `tabindex="-1"`，跳至主要内容链接可将键盘焦点移入主区域。
5. JavaScript 启动时向 `<html>` 增加 `js` 类；小屏仅由 `html.js` 隐藏未展开导航，无 JavaScript 时导航保持普通纵向 flex 展示。
6. 项目页和博客页分别在卡片网格前增加“全部项目”和“全部文章”二级标题。

## 验证

- 已运行 Python 静态回归检查：通过。检查了验证脚本、标题层级、归档、焦点目标、JS 标识、移动导航 CSS 选择器，以及三篇文章的当前日期可构建性。
- 已运行 `git diff --check`：通过，无空白错误。
- 已尝试 Ruby/Jekyll 验证：环境中未安装 Ruby，执行 `ruby --version` 返回 `/usr/bin/bash: line 1: ruby: command not found`（退出码 127）。因此 `bundle exec jekyll build` 与 `ruby scripts/verify_site.rb` 无法在此环境执行。

## 关注项

唯一未完成的运行时验证是 Jekyll 构建与 Ruby 验证脚本，原因是当前环境缺少 Ruby；代码和源文件静态检查已完成。
