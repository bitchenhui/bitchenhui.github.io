#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "pathname"
require "uri"
require "yaml"

SITE = Pathname.new("_site")
PROJECT_FIELDS = %w[title description stack project_url repository_url].freeze
EXPERIENCE_FIELDS = %w[period role summary highlights].freeze
REDIRECT_ROUTES = {
  "projects/index.html" => { source: "projects/index.html", target: "/#projects" },
  "blog/index.html" => { source: "blog/index.html", target: "/#articles" },
  "about/index.html" => { source: "about.md", target: "/#experience" }
}.freeze
CORE_REQUIRED_FILES = (%w[
  index.html
  404.html
  feed.xml
  sitemap.xml
  robots.txt
] + REDIRECT_ROUTES.keys).freeze
APPROVED_SKILL_NAMES = [
  "llm的eoH算法自动迭代设计",
  "视频编解码算法优化(H265/H266/AV1/NVC)",
  "vod/live/rtc场景qos/qoe优化"
].freeze
RUNTIME_SCAN_GLOBS = %w[
  _config.yml
  *.html
  about.md
  robots.txt
  _includes/**/*.html
  _layouts/**/*.html
  assets/**/*.scss
  assets/**/*.js
  blog/**/*.html
  projects/**/*.html
].freeze
OBSOLETE_RUNTIME_MARKERS = %w[
  primary-navigation
  mobile-menu-button
  menuButton
  featured_projects
  查看全部项目
  查看全部文章
].freeze


def load_yaml(path)
  YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true) || {}
rescue Psych::Exception => error
  abort "FAIL: #{path} is not valid YAML: #{error.message}"
end


def front_matter(path)
  match = path.read.match(/\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)/m)
  abort "FAIL: #{path} has no YAML front matter." unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
rescue Psych::Exception => error
  abort "FAIL: #{path} has invalid front matter: #{error.message}"
end


def html_tags(body, name)
  body.scan(/<#{Regexp.escape(name)}\b[^>]*>/im)
end


def attribute_value(tag, name)
  return unless tag

  opening_tag = tag[/\A<[^>]+>/m]
  match = opening_tag&.match(/(?:\A|\s)#{Regexp.escape(name)}\s*=\s*(["'])(.*?)\1/im)
  match && match[2]
end


def relative_site_url(path, baseurl)
  path = "/#{path}" unless path.start_with?("/")
  baseurl.empty? ? path : "#{baseurl}#{path}"
end


def generated_path_for_url(url, baseurl)
  raw_path = CGI.unescapeHTML(url).split(/[?#]/, 2).first
  return if raw_path.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/\/)/i)

  path = URI::DEFAULT_PARSER.unescape(raw_path)
  if baseurl.empty?
    return unless path.start_with?("/")
  else
    return unless path == baseurl || path.start_with?("#{baseurl}/")

    path = path.delete_prefix(baseurl)
  end

  relative_path = path.delete_prefix("/")
  return "index.html" if relative_path.empty?

  relative_path.end_with?("/") ? "#{relative_path}index.html" : relative_path
rescue URI::InvalidURIError
  nil
end

config = Pathname.new("_config.yml")
abort "FAIL: _config.yml is missing." unless config.file?
config_data = load_yaml(config)

site_uri = URI.parse(config_data["url"].to_s)
unless %w[http https].include?(site_uri.scheme) && site_uri.host
  abort "FAIL: _config.yml has no valid HTTP(S) site URL."
end
port = site_uri.port unless [site_uri.default_port, nil].include?(site_uri.port)
site_origin = "#{site_uri.scheme}://#{site_uri.host}#{port ? ":#{port}" : ""}"
baseurl = config_data["baseurl"].to_s.strip
baseurl = "" if baseurl == "/"
baseurl = "/#{baseurl}" unless baseurl.empty? || baseurl.start_with?("/")
baseurl = baseurl.delete_suffix("/")

abort "FAIL: obsolete collections configuration remains." if config_data.key?("collections")
abort "FAIL: obsolete navigation configuration remains." if config_data.key?("navigation")
current_focus = config_data["current_focus"]
unless current_focus.is_a?(Array) && !current_focus.empty? && current_focus.all? { |focus| focus.is_a?(String) && !focus.strip.empty? }
  abort "FAIL: current focus data must be a non-empty list of non-empty strings."
end
skills = config_data["skills"]
unless skills.is_a?(Array) && !skills.empty? && skills.all? { |skill| skill.is_a?(Hash) && %w[name description].all? { |field| skill[field].is_a?(String) && !skill[field].strip.empty? } }
  abort "FAIL: capability data must be a non-empty list matching the required name/description schema."
end
skill_names = skills.map { |skill| skill["name"] }
unless skill_names == APPROVED_SKILL_NAMES
  abort "FAIL: capability names must remain exactly: #{APPROVED_SKILL_NAMES.join(', ')}"
end

projects_data = Pathname.new("_data/projects.yml")
abort "FAIL: project data file is missing." unless projects_data.file?
projects = load_yaml(projects_data)
unless projects.is_a?(Array)
  abort "FAIL: project data must be a list."
end
projects.each_with_index do |project, index|
  missing_fields = PROJECT_FIELDS.reject { |field| project.is_a?(Hash) && project.key?(field) }
  abort "FAIL: project #{index + 1} lacks fields: #{missing_fields.join(', ')}" unless missing_fields.empty?
  abort "FAIL: project #{index + 1} retains obsolete featured data." if project.key?("featured")
  unless project["title"].is_a?(String) && !project["title"].strip.empty? &&
         project["description"].is_a?(String) && !project["description"].strip.empty? &&
         project["stack"].is_a?(Array) && project["stack"].all? { |item| item.is_a?(String) && !item.strip.empty? } &&
         %w[project_url repository_url].all? { |field| project[field].is_a?(String) }
    abort "FAIL: project #{index + 1} has invalid field types or empty required content."
  end
end

experience_data = Pathname.new("_data/experience.yml")
abort "FAIL: experience data file is missing." unless experience_data.file?
experience = load_yaml(experience_data)
unless experience.is_a?(Array)
  abort "FAIL: experience data must be a list."
end
experience.each_with_index do |item, index|
  missing_fields = EXPERIENCE_FIELDS.reject { |field| item.is_a?(Hash) && item.key?(field) }
  abort "FAIL: experience #{index + 1} lacks fields: #{missing_fields.join(', ')}" unless missing_fields.empty?
  unless %w[period role summary].all? { |field| item[field].is_a?(String) && !item[field].strip.empty? } &&
         item["highlights"].is_a?(Array) && item["highlights"].all? { |highlight| highlight.is_a?(String) && !highlight.strip.empty? }
    abort "FAIL: experience #{index + 1} has invalid field types or empty required content."
  end
end

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
abort "FAIL: README still documents obsolete featured project data." if readme_content.include?("featured")

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
head_source = Pathname.new("_includes/head.html").read
footer_source = Pathname.new("_includes/footer.html").read
script_source = Pathname.new("assets/js/site.js").read
style_source = Pathname.new("assets/css/main.scss").read
robots_source = Pathname.new("robots.txt").read

abort "FAIL: header lacks theme control." unless header_source.include?('id="theme-toggle"')
%w[email github linkedin resume_url].each do |field|
  assignment = %({% assign #{field} = site.author.#{field} | default: "" | strip %})
  abort "FAIL: footer does not normalize #{field}." unless footer_source.include?(assignment)
end
abort "FAIL: footer lacks a resume link." unless footer_source.include?("resume_url")
abort "FAIL: footer external links lack safe rel attributes." unless footer_source.include?('rel="noopener noreferrer"')
%w[GitHub（新窗口） LinkedIn（新窗口） 简历（新窗口）].each do |label|
  abort "FAIL: footer external link label lacks new-window disclosure: #{label}." unless footer_source.include?(label)
end

initializer_end = head_source.index('rel="stylesheet"')
initializer = initializer_end && head_source[0...initializer_end]
initializer_markers = ["<script>", "localStorage", "matchMedia", 'theme !== "light"', 'theme !== "dark"', "try", "catch", "dataset.theme"]
missing_initializer_markers = initializer_markers.reject { |marker| initializer&.include?(marker) }
abort "FAIL: pre-stylesheet theme initializer lacks #{missing_initializer_markers.join(', ')}." unless missing_initializer_markers.empty?
abort "FAIL: site controller does not reuse the initialized theme." unless script_source.match?(/initialTheme\s*=\s*root\.dataset\.theme/)
abort "FAIL: site controller does not preserve safe theme writes." unless script_source.include?("try { window.localStorage.setItem")
%w[aria-pressed aria-label].each do |attribute|
  abort "FAIL: theme control does not update #{attribute}." unless script_source.include?(attribute)
end

abort "FAIL: stylesheet still forces a 320px minimum width." if style_source.match?(/\bmin-width\s*:\s*320px/)
abort "FAIL: stylesheet lacks safe wrapping for editable text." unless style_source.match?(/h1,\s*h2,\s*h3,\s*a,\s*\.tag\s*\{[^}]*overflow-wrap:\s*anywhere/m)
header_rule = style_source[/\.site-header\s*\{(.*?)\}/m, 1]
unless header_rule && header_rule.index("background: var(--canvas);") &&
       header_rule.index("background: color-mix(") > header_rule.index("background: var(--canvas);")
  abort "FAIL: site header lacks a pre-color-mix background fallback."
end
abort "FAIL: impossible section-heading child selector remains." if style_source.include?(".section-heading > :last-child")
%w[manual-layout manual-sidebar profile-card position:\ sticky scroll-margin-top].each do |marker|
  abort "FAIL: stylesheet lacks #{marker}." unless style_source.include?(marker.tr("\\", ""))
end
abort "FAIL: desktop content is not pinned to grid column 1." unless style_source.include?(".manual-layout > :not(.manual-sidebar) { min-width: 0; grid-column: 1; }")
abort "FAIL: desktop sidebar placement is incorrect." unless style_source.include?(".manual-sidebar { position: sticky; top: 6rem; grid-column: 2; grid-row: 1 / span 7; }")
short_viewport_fallback = style_source.match?(/\/\/.*sticky offset.*\n@media\s*\(min-width:\s*54\.01rem\)\s*and\s*\(max-height:\s*\d+em\)\s*\{.*?\.manual-sidebar\s*\{[^}]*position:\s*static/m)
abort "FAIL: short wide viewports lack a documented font-relative non-sticky sidebar fallback." unless short_viewport_fallback
abort "FAIL: mobile layout breakpoint is missing." unless style_source.include?("@media (max-width: 54rem)")
abort "FAIL: mobile sidebar placement is incorrect." unless style_source.include?(".manual-sidebar { position: static; grid-row: 2; margin-bottom: 3rem; }")

unless robots_source.start_with?("---\n---\n") && robots_source.include?("{{ '/sitemap.xml' | absolute_url }}")
  abort "FAIL: robots source does not render an absolute sitemap URL through Liquid."
end

runtime_sources = RUNTIME_SCAN_GLOBS.flat_map { |pattern| Pathname.glob(pattern) }.select(&:file?).uniq
runtime_sources.each do |path|
  body = path.read
  obsolete = OBSOLETE_RUNTIME_MARKERS.select { |marker| body.include?(marker) }
  abort "FAIL: obsolete runtime markers remain in #{path}: #{obsolete.join(', ')}" unless obsolete.empty?
end

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
  经历内容待补充。
  项目内容待补充。
  文章内容待更新。
  公开联系方式待补充。
]
missing_home_source_markers = required_home_source_markers.reject { |marker| home_source.include?(marker.tr("\\", "")) }
unless missing_home_source_markers.empty?
  abort "FAIL: homepage source lacks #{missing_home_source_markers.join(', ')}."
end
abort "FAIL: homepage still filters featured projects." if home_source.include?('where: "featured"')
abort "FAIL: homepage still limits primary content." if home_source.match?(/for (project|post).+limit:/)

%w[email github linkedin resume_url].each do |field|
  assignment = %({% assign #{field} = site.author.#{field} | default: "" | strip %})
  abort "FAIL: homepage contact does not normalize #{field}." unless home_source.include?(assignment)
end
contact_source = home_source[/<section id="contact"\b.*?<\/section>/m]
abort "FAIL: homepage contact section is missing." unless contact_source
unless contact_source.include?('{% if email != "" or github != "" or linkedin != "" or resume_url != "" %}')
  abort "FAIL: homepage contact empty state is not conditional on all contact fields."
end
abort "FAIL: homepage contact lacks an email link." unless contact_source.include?("mailto:")
%w[github linkedin resume_url].each do |field|
  link = /href="\{\{ #{field} \| escape \}\}"[^>]*target="_blank"[^>]*rel="noopener noreferrer"[^>]*>/
  abort "FAIL: homepage contact does not safely render #{field}." unless contact_source.match?(link)
end
%w[GitHub（新窗口） LinkedIn（新窗口） 简历（新窗口）].each do |label|
  abort "FAIL: homepage contact external link label lacks new-window disclosure: #{label}." unless contact_source.include?(label)
end

post_card_source = Pathname.new("_includes/post-card.html").read
unless post_card_source.include?('aria-label="阅读全文：{{ include.post.title | escape }}"')
  abort "FAIL: post-card action lacks an article-specific accessible name."
end

REDIRECT_ROUTES.each_value do |route|
  path = route.fetch(:source)
  target = route.fetch(:target)
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

post_files = Pathname.glob("_posts/*").select(&:file?)
post_metadata = post_files.to_h { |post| [post, front_matter(post)] }

abort "FAIL: _site does not exist; run `bundle exec jekyll build` first." unless SITE.directory?
missing = CORE_REQUIRED_FILES.reject { |path| (SITE / path).file? }
abort "FAIL: missing generated files: #{missing.join(', ')}" unless missing.empty?

html_files = SITE.glob("**/*.html")
abort "FAIL: no generated HTML pages found." if html_files.empty?
generated_html = html_files.to_h do |file|
  relative_path = file.relative_path_from(SITE).each_filename.to_a.join("/")
  [relative_path, file.read]
end
generated_html.each do |path, body|
  abort "FAIL: #{path} has no lang=\"zh-CN\" document language." unless body.include?('lang="zh-CN"')
  abort "FAIL: #{path} has no viewport metadata." unless body.include?('name="viewport"')
  abort "FAIL: #{path} contains an empty href attribute." if body.match?(/href=["']\s*["']/)
end

home = generated_html.fetch("index.html")
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

project_titles = projects.map { |project| project["title"] }
missing_projects = project_titles.reject { |title| home.include?(CGI.escapeHTML(title)) }
abort "FAIL: homepage omits projects: #{missing_projects.join(', ')}" unless missing_projects.empty?
post_titles = post_metadata.values.map { |data| data["title"].to_s }
missing_posts = post_titles.reject { |title| home.include?(CGI.escapeHTML(title)) }
abort "FAIL: homepage omits posts: #{missing_posts.join(', ')}" unless missing_posts.empty?

article_links = home.scan(/<a\b[^>]*>.*?<\/a\s*>/im)
                    .select { |tag| tag.include?("阅读全文") }
                    .filter_map { |tag| attribute_value(tag, "href") }
                    .uniq
article_outputs = article_links.filter_map { |url| generated_path_for_url(url, baseurl) }
unresolved_articles = article_links.reject do |url|
  output = generated_path_for_url(url, baseurl)
  output && generated_html.key?(output)
end
unless unresolved_articles.empty?
  abort "FAIL: homepage article links do not resolve to generated HTML: #{unresolved_articles.join(', ')}"
end
unless article_outputs.uniq.length == post_metadata.length
  abort "FAIL: homepage exposes #{article_outputs.uniq.length} generated article route(s) for #{post_metadata.length} source post(s)."
end
required_files = (CORE_REQUIRED_FILES + article_outputs).uniq.freeze

REDIRECT_ROUTES.each do |path, route|
  target = route.fetch(:target)
  body = generated_html.fetch(path)
  relative_target = relative_site_url(target, baseurl)
  absolute_target = "#{site_origin}#{relative_target}"

  refresh = html_tags(body, "meta").find do |tag|
    attribute_value(tag, "http-equiv")&.casecmp?("refresh")
  end
  refresh_content = attribute_value(refresh, "content")
  unless refresh_content&.match?(/\A\s*\d+\s*;\s*url\s*=\s*#{Regexp.escape(relative_target)}\s*\z/i)
    abort "FAIL: #{path} lacks refresh target #{relative_target}."
  end

  canonical = html_tags(body, "link").find do |tag|
    attribute_value(tag, "rel")&.split&.any? { |rel| rel.casecmp?("canonical") }
  end
  unless attribute_value(canonical, "href") == absolute_target
    abort "FAIL: #{path} lacks canonical target #{absolute_target}."
  end

  fallback = body.scan(/<a\b[^>]*>.*?<\/a\s*>/im).find { |tag| tag.include?("继续前往") }
  unless attribute_value(fallback, "href") == relative_target
    abort "FAIL: #{path} lacks clickable fallback to #{relative_target}."
  end
end

not_found = generated_html.fetch("404.html")
abort "FAIL: 404 page lacks the home link." unless not_found.include?("返回首页")
feed = (SITE / "feed.xml").read
abort "FAIL: feed output has no feed element." unless feed.include?("<feed")
abort "FAIL: feed output has no Atom media type." unless feed.include?("application/atom+xml")
expected_sitemap_url = "#{site_origin}#{relative_site_url('/sitemap.xml', baseurl)}"
robots = (SITE / "robots.txt").read
abort "FAIL: robots output lacks sitemap URL #{expected_sitemap_url}." unless robots.lines.any? { |line| line.strip == "Sitemap: #{expected_sitemap_url}" }
sitemap = (SITE / "sitemap.xml").read
expected_home_url = "#{site_origin}#{relative_site_url('/', baseurl)}"
home_loc_pattern = /<loc>\s*#{Regexp.escape(expected_home_url)}\s*<\/loc>/
abort "FAIL: sitemap output has no canonical home URL #{expected_home_url}." unless sitemap.match?(home_loc_pattern)

puts "PASS: verified #{generated_html.length} HTML file(s) and #{required_files.length} required site file(s)."
