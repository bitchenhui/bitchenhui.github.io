#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

SITE = Pathname.new("_site")
REQUIRED_FILES = %w[
  index.html
  projects/index.html
  blog/index.html
  about/index.html
  404.html
  feed.xml
  sitemap.xml
  robots.txt
].freeze

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

puts "PASS: verified #{html_files.length} HTML file(s) and #{REQUIRED_FILES.length} required site file(s)."
