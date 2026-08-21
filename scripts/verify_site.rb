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
blog_index = (SITE / "blog/index.html").read
abort "FAIL: blog index lacks its empty-state fallback." unless blog_index.include?("暂时还没有文章")

puts "PASS: verified #{html_files.length} HTML file(s) and #{REQUIRED_FILES.length} required site file(s)."
