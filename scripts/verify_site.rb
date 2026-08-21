#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

SITE = Pathname.new("_site")
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

projects_data = Pathname.new("_data/projects.yml")
abort "FAIL: project data file is missing." unless projects_data.file?

projects_content = projects_data.read
abort "FAIL: project data has no featured item." unless projects_content.include?("featured: true")
abort "FAIL: project data has no explicit placeholder marker." unless projects_content.include?("TODO: 替换为")

readme = Pathname.new("README.md")
abort "FAIL: README is missing." unless readme.file?

readme_content = readme.read
required_readme_sections = %w[本地预览 写文章 添加项目 独立域名]
missing_readme_sections = required_readme_sections.reject { |section| readme_content.include?(section) }
unless missing_readme_sections.empty?
  abort "FAIL: README is missing required sections: #{missing_readme_sections.join(', ')}"
end

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

index = (SITE / "index.html").read
required_index_markers = %w[
  id=\"primary-navigation\"
  id=\"theme-toggle\"
  /assets/css/main.css
  /assets/js/site.js
]
missing_markers = required_index_markers.reject { |marker| index.include?(marker) }
abort "FAIL: index.html is missing shell markers: #{missing_markers.join(', ')}" unless missing_markers.empty?

home = (SITE / "index.html").read
abort "FAIL: home page lacks the hero heading." unless home.include?("个人网站首版示例")
blog_source = Pathname.new("blog/index.html")
abort "FAIL: blog source page is missing." unless blog_source.file?
abort "FAIL: blog source lacks its empty-state fallback." unless blog_source.read.include?("暂时还没有文章")
blog_index = (SITE / "blog/index.html").read
abort "FAIL: blog index lacks the rendered post title." unless blog_index.include?("编码性能分析：先建立可复现的基线")

not_found = (SITE / "404.html").read
abort "FAIL: 404 page lacks the home link." unless not_found.include?("返回首页")
feed = (SITE / "feed.xml").read
abort "FAIL: feed output has no feed element." unless feed.include?("<feed")
abort "FAIL: feed output has no Atom media type." unless feed.include?("application/atom+xml")
robots = (SITE / "robots.txt").read
abort "FAIL: robots output has no sitemap directive." unless robots.include?("Sitemap:")
sitemap = (SITE / "sitemap.xml").read
abort "FAIL: sitemap output has no canonical site URL." unless sitemap.include?("https://bitchenhui.github.io/")

puts "PASS: verified #{html_files.length} HTML file(s) and #{REQUIRED_FILES.length} required site file(s)."
