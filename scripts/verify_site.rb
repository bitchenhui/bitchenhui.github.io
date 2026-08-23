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

def html_tags(body, name)
  body.scan(/<#{Regexp.escape(name)}\b[^>]*>/im)
end

def attribute_value(tag, name)
  return unless tag

  opening_tag = tag[/\A<[^>]+>/m]
  match = opening_tag&.match(/(?:\A|\s)#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im)
  match && match[2]
end

projects_data = Pathname.new("_data/projects.yml")
abort "FAIL: project data file is missing." unless projects_data.file?

projects_content = projects_data.read
abort "FAIL: project data has no featured item." unless projects_content.include?("featured: true")
abort "FAIL: project data has no explicit placeholder marker." unless projects_content.include?("TODO: 替换为")

readme = Pathname.new("README.md")
abort "FAIL: README is missing." unless readme.file?

readme_content = readme.read
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
unless missing_readme_sections.empty?
  abort "FAIL: README is missing required sections: #{missing_readme_sections.join(', ')}"
end

config = Pathname.new("_config.yml")
abort "FAIL: _config.yml is missing." unless config.file?
config_content = config.read
site_url = config_content[/^url:\s*["']?([^"'\s]+)["']?/, 1]
abort "FAIL: _config.yml has no site URL." unless site_url
site_url = site_url.delete_suffix("/")

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
  body = file.read
  missing_markers = markers.reject { |marker| body.include?(marker) }
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

home_source = Pathname.new("index.html").read
required_home_source_markers = %w[
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
missing_home_source_markers = required_home_source_markers.reject { |marker| home_source.include?(marker.tr("\\", "")) }
unless missing_home_source_markers.empty?
  abort "FAIL: homepage source lacks #{missing_home_source_markers.join(', ')}."
end
abort "FAIL: homepage still filters featured projects." if home_source.include?('where: "featured"')
abort "FAIL: homepage still limits primary content." if home_source.match?(/for (project|post).+limit:/)

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
  fallback_href = 'href="{{ page.redirect_to | relative_url }}"'
  abort "FAIL: #{path} fallback does not use page.redirect_to." unless body.include?(fallback_href)
end

post_source = Pathname.new("_layouts/post.html").read
abort "FAIL: post layout does not return to /#articles." unless post_source.include?("/#articles")
abort "FAIL: post layout still links to /blog/." if post_source.include?('href="{{ \'/blog/\'')

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

redirect_outputs = {
  "projects/index.html" => "/#projects",
  "blog/index.html" => "/#articles",
  "about/index.html" => "/#experience"
}.freeze
redirect_outputs.each do |path, target|
  body = (SITE / path).read
  refresh = html_tags(body, "meta").find do |tag|
    attribute_value(tag, "http-equiv")&.casecmp?("refresh")
  end
  refresh_content = attribute_value(refresh, "content")
  unless refresh_content&.match?(/\A\s*\d+\s*;\s*url\s*=\s*#{Regexp.escape(target)}\s*\z/i)
    abort "FAIL: #{path} lacks refresh target #{target}."
  end

  canonical = html_tags(body, "link").find do |tag|
    attribute_value(tag, "rel")&.split&.any? { |rel| rel.casecmp?("canonical") }
  end
  canonical_target = "#{site_url}#{target}"
  unless attribute_value(canonical, "href") == canonical_target
    abort "FAIL: #{path} lacks canonical target #{canonical_target}."
  end

  fallback = body.scan(/<a\b[^>]*>.*?<\/a\s*>/im).find { |tag| tag.include?("继续前往") }
  unless attribute_value(fallback, "href") == target
    abort "FAIL: #{path} lacks clickable fallback to #{target}."
  end
end

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
