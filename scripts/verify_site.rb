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

header_source = Pathname.new("_includes/header.html").read
footer_source = Pathname.new("_includes/footer.html").read
script_source = Pathname.new("assets/js/site.js").read
style_source = Pathname.new("assets/css/main.scss").read

abort "FAIL: header lacks theme control." unless header_source.include?('id="theme-toggle"')
%w[mobile-menu-button primary-navigation site.navigation].each do |obsolete|
  abort "FAIL: obsolete header marker remains: #{obsolete}." if header_source.include?(obsolete)
end
%w[menuButton navigation is-open].each do |obsolete|
  abort "FAIL: obsolete menu script remains: #{obsolete}." if script_source.include?(obsolete)
end
%w[email github linkedin resume_url].each do |field|
  assignment = %({% assign #{field} = site.author.#{field} | default: "" | strip %})
  abort "FAIL: footer does not normalize #{field}." unless footer_source.include?(assignment)
end
abort "FAIL: footer lacks a resume link." unless footer_source.include?("resume_url")
abort "FAIL: footer external links lack safe rel attributes." unless footer_source.include?('rel="noopener noreferrer"')
%w[manual-layout manual-sidebar profile-card position:\ sticky scroll-margin-top].each do |marker|
  abort "FAIL: stylesheet lacks #{marker}." unless style_source.include?(marker.tr("\\", ""))
end
abort "FAIL: desktop content is not pinned to grid column 1." unless style_source.include?(".manual-layout > :not(.manual-sidebar) { min-width: 0; grid-column: 1; }")
abort "FAIL: desktop sidebar placement is incorrect." unless style_source.include?(".manual-sidebar { position: sticky; top: 6rem; grid-column: 2; grid-row: 1 / span 7; }")
abort "FAIL: mobile sidebar placement is incorrect." unless style_source.include?(".manual-sidebar { position: static; grid-row: 2; margin-bottom: 3rem; }")

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
  id=\"theme-toggle\"
  /assets/css/main.css
  /assets/js/site.js
]
missing_markers = required_index_markers.reject { |marker| index.include?(marker) }
abort "FAIL: index.html is missing shell markers: #{missing_markers.join(', ')}" unless missing_markers.empty?

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
