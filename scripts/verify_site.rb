#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "pathname"
require "time"
require "uri"
require "yaml"

SITE = Pathname.new(ARGV.fetch(0, "_site"))
PROJECT_FIELDS = %w[title description stack].freeze
PROJECT_URL_FIELDS = %w[project_url repository_url].freeze
EXPERIENCE_FIELDS = %w[period role summary highlights].freeze
REDIRECT_ROUTES = {
  "projects/index.html" => { source: "projects/index.html", target: "/#projects" },
  "blog/index.html" => { source: "blog/index.html", target: "/" },
  "about/index.html" => { source: "about.md", target: "/#experience" }
}.freeze
CORE_REQUIRED_FILES = (%w[
  index.html
  404.html
  feed.xml
  sitemap.xml
  robots.txt
  resume/index.html
] + REDIRECT_ROUTES.keys).freeze
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
  match = path.read.match(/\A---[^\S\r\n]*\r?\n(.*?)^---[^\S\r\n]*(?:\r?\n|\z)/m)
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


def html_blocks(body, class_name)
  body.scan(/<article\b(?=[^>]*\bclass\s*=\s*["'][^"']*\b#{Regexp.escape(class_name)}\b)[^>]*>.*?<\/article\s*>/im)
end


def html_elements(body, name)
  body.scan(/<#{Regexp.escape(name)}\b[^>]*>.*?<\/#{Regexp.escape(name)}\s*>/im)
end


def html_text(block)
  CGI.unescapeHTML(block.gsub(/<[^>]*>/m, "")).gsub(/\s+/, " ").strip
end


def relative_site_url(path, baseurl)
  path = "/#{path}" unless path.start_with?("/")
  baseurl.empty? ? path : "#{baseurl}#{path}"
end


def generated_path_for_url(url, baseurl)
  path = URI::DEFAULT_PARSER.unescape(url)
  return if path.split("/").include?("..")
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
baseurl = ARGV.fetch(1, config_data["baseurl"]).to_s.strip
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

projects_data = Pathname.new("_data/projects.yml")
abort "FAIL: project data file is missing." unless projects_data.file?
projects = load_yaml(projects_data)
unless projects.is_a?(Array)
  abort "FAIL: project data must be a list."
end
projects.each_with_index do |project, index|
  missing_fields = PROJECT_FIELDS.reject { |field| project.is_a?(Hash) && project.key?(field) }
  abort "FAIL: project #{index + 1} lacks fields: #{missing_fields.join(', ')}" unless missing_fields.empty?
  unless project["title"].is_a?(String) && !project["title"].strip.empty? &&
         project["description"].is_a?(String) && !project["description"].strip.empty? &&
         project["stack"].is_a?(Array) && project["stack"].all? { |item| item.is_a?(String) && !item.strip.empty? } &&
         PROJECT_URL_FIELDS.all? { |field| !project.key?(field) || project[field].is_a?(String) }
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

required_includes = {
  "_includes/profile-card.html" => ["profile-card", "site.current_focus", "site.data.honors", "site.author.wechat"],
  "_includes/experience-item.html" => ["experience-item", "include.item.highlights"],
  "_includes/project-card.html" => ["project_url", "repository_url", "project-card__cover", "project-card__highlights"]
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

abort "FAIL: header must not keep a palette selector." if header_source.include?("palette")
abort "FAIL: header must not keep display-setting controls." if header_source.include?("quality-toggle") || header_source.include?("palette")
resume_source = Pathname.new("resume/index.html").read
%w[site.data.experience site.data.projects site.skills data-print-button].each do |marker|
  abort "FAIL: resume page lacks #{marker}." unless resume_source.include?(marker)
end
hidden_rule = style_source.match?(/\[hidden\]\s*\{[^}]*display:\s*none\s*!important\s*;/m)
hidden_rule_position = style_source.index("[hidden]")
button_rule_position = style_source.index(".icon-button")
unless hidden_rule && hidden_rule_position && button_rule_position && hidden_rule_position < button_rule_position
  abort "FAIL: stylesheet must hide [hidden] elements before icon-button display rules."
end
%w[email github linkedin resume_url].each do |field|
  assignment = %({% assign #{field} = site.author.#{field} | default: "" | strip %})
  abort "FAIL: footer does not normalize #{field}." unless footer_source.include?(assignment)
end
abort "FAIL: footer lacks a resume link." unless footer_source.include?("resume_url")
abort "FAIL: footer external links lack safe rel attributes." unless footer_source.include?('rel="noopener noreferrer"')
%w[GitHub（新窗口） LinkedIn（新窗口） 简历（新窗口）].each do |label|
  abort "FAIL: footer external link label lacks new-window disclosure: #{label}." unless footer_source.include?(label)
end

abort "FAIL: pre-stylesheet inline scripts must stay removed." if head_source.index("<script>") && head_source.index("<script>") < head_source.index('rel="stylesheet"')
abort "FAIL: styles must not keep palette theming hooks." if style_source.include?("data-palette")
abort "FAIL: styles must not keep quality theming hooks." if style_source.include?("data-quality")
abort "FAIL: scripts must not keep the quality toggle." if script_source.include?("quality-toggle")
%w[
  rel="icon"
  property="og:title"
  property="og:description"
  name="twitter:card"
  application/ld+json
].each do |marker|
  abort "FAIL: head lacks SEO marker #{marker}." unless head_source.include?(marker)
end
abort "FAIL: stylesheet lacks print rules." unless style_source.include?("@media print")
abort "FAIL: stylesheet lacks project card highlight styles." unless style_source.include?(".project-card__highlights")

abort "FAIL: stylesheet still forces a 320px minimum width." if style_source.match?(/\bmin-width\s*:\s*320px/)
abort "FAIL: stylesheet lacks safe wrapping for editable text." unless style_source.match?(/h1,\s*h2,\s*h3,\s*a,\s*\.tag\s*\{[^}]*overflow-wrap:\s*anywhere/m)
prose_rule_body = style_source[/\.prose\s*\{([^}]*)\}/m, 1]
abort "FAIL: prose rule is missing." unless prose_rule_body
abort "FAIL: prose overrides shell gutters." if prose_rule_body.match?(/(?:\A|;)\s*width\s*:/m)
abort "FAIL: prose lacks a readable maximum width." unless prose_rule_body.match?(/(?:\A|;)\s*max-width:\s*var\(--reading\)/m)
unless style_source.match?(/\.prose pre,\s*\.prose table\s*\{[^}]*max-width:\s*100%[^}]*overflow-x:\s*auto/m) &&
       style_source.match?(/\.prose table\s*\{[^}]*display:\s*block/m) &&
       style_source.match?(/\.prose code,\s*\.prose p,\s*\.prose li\s*\{[^}]*overflow-wrap:\s*anywhere/m) &&
       style_source.match?(/\.prose img\s*\{[^}]*max-width:\s*100%[^}]*height:\s*auto/m)
  abort "FAIL: prose lacks robust local overflow handling."
end
header_rule = style_source[/\.site-header\s*\{(.*?)\}/m, 1]
unless header_rule && header_rule.index("background: var(--canvas);") &&
       header_rule.index("background: color-mix(") > header_rule.index("background: var(--canvas);")
  abort "FAIL: site header lacks a pre-color-mix background fallback."
end
abort "FAIL: impossible section-heading child selector remains." if style_source.include?(".section-heading > :last-child")
%w[manual-layout manual-sidebar profile-card position:\ sticky scroll-margin-top].each do |marker|
  abort "FAIL: stylesheet lacks #{marker}." unless style_source.include?(marker.tr("\\", ""))
end

robots_path = Pathname.new("robots.txt")
front_matter(robots_path)
unless robots_source.include?("{{ '/sitemap.xml' | absolute_url }}")
  abort "FAIL: robots source does not render an absolute sitemap URL through Liquid."
end

runtime_sources = RUNTIME_SCAN_GLOBS.flat_map { |pattern| Pathname.glob(pattern) }.select(&:file?).uniq
runtime_sources.each do |path|
  body = path.read
  obsolete = OBSOLETE_RUNTIME_MARKERS.select { |marker| body.include?(marker) }
  abort "FAIL: obsolete runtime markers remain in #{path}: #{obsolete.join(', ')}" unless obsolete.empty?
end

home_source = Pathname.new("index.html").read
home_sections = {
  "experience" => { condition: /\{%\s*if\s+site\.data\.experience\s+and\s+site\.data\.experience\s*!=\s*empty\s*%\}/, empty: "经历内容待补充." },
  "projects" => { condition: /\{%\s*if\s+site\.data\.projects\s+and\s+site\.data\.projects\s*!=\s*empty\s*%\}/, empty: "作品截图整理中." },
  "contact" => { condition: /\{%\s*if\s+email\s*!=\s*""\s+or\s+wechat\s*!=\s*""\s+or\s+github\s*!=\s*""\s+or\s+linkedin\s*!=\s*""\s+or\s+resume_url\s*!=\s*""\s*%\}/, empty: "公开联系方式待补充." }
}.freeze
home_sections.each do |id, contract|
  section = home_source[/<section id="#{Regexp.escape(id)}"(?=[\s>]).*?<\/section>/m]
  abort "FAIL: homepage source lacks the #{id} section." unless section
  branch = section.match(/#{contract.fetch(:condition).source}(.*?)\{%\s*else\s*%\}(.*?)\{%\s*endif\s*%\}/m)
  unless branch && branch[2].include?(contract.fetch(:empty))
    abort "FAIL: homepage #{id} empty state is not in its reachable Liquid else branch."
  end
end
required_home_source_markers = %w[
  id="capabilities"
  id="experience"
  id="projects"
  id="contact"
  include\ profile-card.html
  include\ experience-item.html
  site.data.projects
  site.data.education
  hero-decode
  include\ signal-frame.html
]
missing_home_source_markers = required_home_source_markers.reject { |marker| home_source.include?(marker.tr("\\", "")) }
unless missing_home_source_markers.empty?
  abort "FAIL: homepage source lacks #{missing_home_source_markers.join(', ')}."
end
abort "FAIL: homepage still filters featured projects." if home_source.include?('where: "featured"')
abort "FAIL: homepage still limits primary content." if home_source.match?(/for (project|post).+limit:/)
unless home_source.match?(/\{%\s*if\s+site\.data\.projects\s+and\s+site\.data\.projects\s*!=\s*empty\s*%\}/)
  abort "FAIL: homepage must render site.data.projects conditionally."
end

%w[email wechat github linkedin resume_url].each do |field|
  assignment = %({% assign #{field} = site.author.#{field} | default: "" | strip %})
  abort "FAIL: homepage contact does not normalize #{field}." unless home_source.include?(assignment)
end
contact_source = home_source[/<section id="contact"(?=[\s>]).*?<\/section>/m]
abort "FAIL: homepage contact section is missing." unless contact_source
unless contact_source.include?('{% if email != "" or wechat != "" or github != "" or linkedin != "" or resume_url != "" %}')
  abort "FAIL: homepage contact empty state is not conditional on all contact fields."
end
abort "FAIL: homepage contact lacks an email link." unless contact_source.include?("mailto:")
abort "FAIL: homepage contact lacks a copyable WeChat action." unless contact_source.include?("data-copy-wechat")
abort "FAIL: homepage contact copy button must come from site.author.wechat." unless contact_source.include?("data-copy-wechat=\"{{ wechat | escape }}\"")

REDIRECT_ROUTES.each_value do |route|
  path = route.fetch(:source)
  target = route.fetch(:target)
  body = Pathname.new(path).read
  abort "FAIL: #{path} lacks redirect target #{target}." unless body.include?("redirect_to: #{target}")
  abort "FAIL: #{path} lacks canonical target #{target}." unless body.include?("canonical_url: #{target}")
  route_data = front_matter(Pathname.new(path))
  abort "FAIL: #{path} must be excluded from the sitemap." unless route_data["sitemap"] == false
  abort "FAIL: #{path} lacks a fallback link." unless body.include?("继续前往")
  fallback_href = 'href="{{ page.redirect_to | relative_url }}"'
  abort "FAIL: #{path} fallback does not use page.redirect_to." unless body.include?(fallback_href)
end

post_source_absent = !Pathname.new("_layouts/post.html").exist?
abort "FAIL: article phase is retired; _layouts/post.html should stay removed." unless post_source_absent

abort "FAIL: #{SITE} does not exist; run `bundle exec jekyll build` first." unless SITE.directory?
missing = CORE_REQUIRED_FILES.reject { |path| (SITE / path).file? }
abort "FAIL: missing generated files: #{missing.join(', ')}" unless missing.empty?

html_files = SITE.glob("**/*.html")
abort "FAIL: no generated HTML pages found." if html_files.empty?
generated_html = html_files.to_h do |file|
  relative_path = file.relative_path_from(SITE).each_filename.to_a.join("/")
  [relative_path, file.read]
end
ids_by_page = generated_html.transform_values do |body|
  body.scan(/<[a-z][^>]*>/i).filter_map { |tag| attribute_value(tag, "id") }
end
generated_html.each do |path, body|
  abort "FAIL: #{path} has no lang=\"zh-CN\" document language." unless body.include?('lang="zh-CN"')
  abort "FAIL: #{path} has no viewport metadata." unless body.include?('name="viewport"')
  ids = ids_by_page.fetch(path)
  abort "FAIL: #{path} contains duplicate IDs." unless ids.uniq == ids

  { "a" => "href", "link" => "href", "script" => "src", "img" => "src" }.each do |tag_name, attribute|
    html_tags(body, tag_name).each do |tag|
      raw = attribute_value(tag, attribute)
      next unless raw

      url = CGI.unescapeHTML(raw).strip
      abort "FAIL: #{path} contains an empty #{attribute}." if url.empty?
      url = url.delete_prefix(site_origin) if url.start_with?("#{site_origin}/")
      next if url.start_with?("//") || !url.start_with?("/", "#")

      target, fragment = url.split("#", 2)
      target = target.split("?", 2).first.to_s
      destination = target.empty? ? path : generated_path_for_url(target, baseurl)
      unless destination && (SITE / destination).file?
        abort "FAIL: #{path} references missing local URL #{url}."
      end
      if fragment && !fragment.empty? && !ids_by_page.fetch(destination, []).include?(URI::DEFAULT_PARSER.unescape(fragment))
        abort "FAIL: #{path} references missing anchor #{url}."
      end
    end
  end
end

home = generated_html.fetch("index.html")
expected_stylesheet_url = relative_site_url("/assets/css/main.css", baseurl)
expected_script_url = relative_site_url("/assets/js/site.js", baseurl)
stylesheet = html_tags(home, "link").find do |tag|
  attribute_value(tag, "rel")&.split&.any? { |rel| rel.casecmp?("stylesheet") } &&
    attribute_value(tag, "href") == expected_stylesheet_url
end
abort "FAIL: generated homepage lacks stylesheet URL #{expected_stylesheet_url}." unless stylesheet
script = html_tags(home, "script").find { |tag| attribute_value(tag, "src") == expected_script_url }
abort "FAIL: generated homepage script URL is not #{expected_script_url}." unless script
home_script = relative_site_url("/assets/js/home.js", baseurl)
generated_html.each do |path, body|
  loads_home_script = html_tags(body, "script").any? { |tag| attribute_value(tag, "src") == home_script }
  abort "FAIL: #{path} loads the wrong page scripts." unless loads_home_script == (path == "index.html")
end
resume_path = relative_site_url("/resume/", baseurl)
unless html_tags(home, "a").any? { |tag| attribute_value(tag, "href") == resume_path }
  abort "FAIL: the online resume is not reachable from the homepage."
end
required_home_markers = %w[
  id="capabilities"
  id="experience"
  id="projects"
  id="contact"
  class="profile-card"
]
missing_markers = required_home_markers.reject { |marker| home.include?(marker) }
abort "FAIL: generated homepage lacks #{missing_markers.join(', ')}." unless missing_markers.empty?
%w[primary-navigation mobile-menu-button].each do |obsolete|
  abort "FAIL: generated homepage retains #{obsolete}." if home.include?(obsolete)
end

project_cards = html_blocks(home, "project-card")
project_link_labels = { "project_url" => "查看项目（新窗口）", "repository_url" => "查看代码（新窗口）" }.freeze
missing_projects = projects.filter_map do |project|
  title = project["title"]
  escaped_title = CGI.escapeHTML(title)
  escaped_description = CGI.escapeHTML(project["description"])
  card_index = project_cards.index do |card|
    stack_tags = card.scan(/<li\b[^>]*class=["'][^"']*\btag\b[^"']*["'][^>]*>.*?<\/li\s*>/im).map { |tag| html_text(tag) }
    valid_links = PROJECT_URL_FIELDS.all? do |field|
      url = project[field].to_s.strip
      labelled_links = html_elements(card, "a").select { |link| html_text(link) == project_link_labels.fetch(field) }
      if url.empty?
        labelled_links.empty?
      else
        link = labelled_links.find { |candidate| attribute_value(candidate, "href") == CGI.escapeHTML(url) }
        link && labelled_links.length == 1 &&
          attribute_value(link, "target") == "_blank" && attribute_value(link, "rel") == "noopener noreferrer"
      end
    end
    card.match?(/<h3\b[^>]*>\s*#{Regexp.escape(escaped_title)}\s*<\/h3>/m) &&
      card.match?(/<p\b[^>]*>\s*#{Regexp.escape(escaped_description)}\s*<\/p>/m) &&
      stack_tags.sort == project["stack"].map(&:to_s).sort && valid_links
  end
  next title unless card_index

  project_cards.delete_at(card_index)
  nil
end
abort "FAIL: homepage project cards omit project details: #{missing_projects.join(', ')}" unless missing_projects.empty?
abort "FAIL: homepage exposes #{project_cards.length} unexpected project card(s)." unless project_cards.empty?

REDIRECT_ROUTES.each do |path, route|
  target = route.fetch(:target)
  body = generated_html.fetch(path)
  relative_target = relative_site_url(target, baseurl)
  absolute_target = "#{site_origin}#{relative_target}"

  refresh = html_tags(body, "meta").find do |tag|
    attribute_value(tag, "http-equiv")&.casecmp?("refresh")
  end
  refresh_content = attribute_value(refresh, "content")
  unless refresh_content&.match?(/\A\s*0\s*;\s*url\s*=\s*#{Regexp.escape(relative_target)}\s*\z/i)
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
expected_home_path = relative_site_url("/", baseurl)
not_found_home_link = not_found.scan(/<a\b[^>]*>.*?<\/a\s*>/im).find do |tag|
  attribute_value(tag, "href") == expected_home_path && tag.match?(/>\s*返回首页\s*<\/a\s*>/m)
end
abort "FAIL: 404 page lacks a home link to #{expected_home_path}." unless not_found_home_link
feed = (SITE / "feed.xml").read
abort "FAIL: feed output has no feed element." unless feed.include?("<feed")
abort "FAIL: feed output has no Atom media type." unless feed.include?("application/atom+xml")
expected_sitemap_url = "#{site_origin}#{relative_site_url('/sitemap.xml', baseurl)}"
robots = (SITE / "robots.txt").read
abort "FAIL: robots output lacks sitemap URL #{expected_sitemap_url}." unless robots.lines.any? { |line| line.strip == "Sitemap: #{expected_sitemap_url}" }
sitemap = (SITE / "sitemap.xml").read
expected_home_url = "#{site_origin}#{relative_site_url('/', baseurl)}"
home_loc_pattern = /<loc>\s*#{Regexp.escape(expected_home_url)}\s*<\/loc>/
unless sitemap.scan(home_loc_pattern).length == 1
  abort "FAIL: sitemap must contain canonical home URL #{expected_home_url} exactly once."
end
blog_article_locs = sitemap.scan(%r{<loc>\s*#{Regexp.escape(site_origin)}#{Regexp.escape(relative_site_url('/blog/', baseurl))}[^<]*</loc>})
abort "FAIL: sitemap must not advertise retired article routes." unless blog_article_locs.empty?
REDIRECT_ROUTES.each_key do |path|
  route_path = "/#{path.delete_suffix('index.html')}"
  compatibility_paths = [route_path, "#{route_path}index.html"]
  compatibility_paths.each do |compatibility_path|
    compatibility_url = "#{site_origin}#{relative_site_url(compatibility_path, baseurl)}"
    compatibility_loc = /<loc>\s*#{Regexp.escape(compatibility_url)}\s*<\/loc>/
    abort "FAIL: sitemap advertises compatibility route #{compatibility_url}." if sitemap.match?(compatibility_loc)
  end
end
resume_output = generated_html.fetch("resume/index.html")
%w[id="resume-title" 当前关注 核心能力 工作经历 个人作品 教育背景 收获].each do |marker|
  abort "FAIL: generated resume page lacks #{marker}." unless resume_output.include?(marker)
end
abort "FAIL: resume must label works as 个人作品, not 项目经历." if resume_output.include?("项目经历")
resume_url_pattern = /<loc>\s*#{Regexp.escape("#{site_origin}#{relative_site_url('/resume/', baseurl)}")}\s*<\/loc>/
unless sitemap.scan(resume_url_pattern).length == 1
  abort "FAIL: sitemap must contain the resume URL exactly once."
end

required_files = CORE_REQUIRED_FILES.freeze
puts "PASS: verified #{generated_html.length} HTML file(s) and #{required_files.length} required site file(s)."
