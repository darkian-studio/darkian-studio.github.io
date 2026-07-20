#!/usr/bin/env ruby
# frozen_string_literal: true

# Structural, SEO/AEO, and guardrail tests for the built Jekyll site (_site).
# Run after `jekyll build`. Exits non-zero on any failure.

require "json"
require "nokogiri"

SITE = File.expand_path("../_site", __dir__)

# Setup command must match the public README verbatim (ticket §11, §15).
README_COMMAND =
  "pkg install curl; curl -fsSL https://raw.githubusercontent.com/darkian-studio/app/main/install.sh | bash"

# Core facts must be worded identically across pages for AEO (ticket §9).
AI_CRAWLERS = %w[GPTBot ClaudeBot PerplexityBot Google-Extended].freeze

@failures = []
def check(desc)
  ok = yield
  puts(ok ? "  ok   #{desc}" : "  FAIL #{desc}")
  @failures << desc unless ok
rescue => e
  puts "  FAIL #{desc} (#{e.class}: #{e.message})"
  @failures << desc
end

def read(rel)
  File.read(File.join(SITE, rel))
end

def doc(rel)
  Nokogiri::HTML(read(rel))
end

# --- §6 sitemap: every page exists ------------------------------------------
PAGES = {
  "index.html"                       => "Home",
  "install/index.html"               => "Install",
  "docs/index.html"                  => "Docs index",
  "docs/getting-started/index.html"  => "Getting started",
  "docs/architecture/index.html"     => "Architecture",
  "docs/dsterm/index.html"           => "dsterm",
  "docs/troubleshooting/index.html"  => "Troubleshooting",
  "docs/vs-vscode/index.html"        => "Comparison: VS Code",
  "docs/vs-acode/index.html"         => "Comparison: Acode",
  "changelog/index.html"             => "Changelog",
  "faq/index.html"                   => "FAQ",
  "404.html"                         => "404"
}.freeze

ROOT_FILES = %w[sitemap.xml robots.txt llms.txt assets/images/og-default.png].freeze

puts "== Files exist (§6) =="
PAGES.each { |f, name| check("page present: #{name} (#{f})") { File.exist?(File.join(SITE, f)) } }
ROOT_FILES.each { |f| check("file present: #{f}") { File.exist?(File.join(SITE, f)) } }

# --- Per-page SEO hygiene (§8) ----------------------------------------------
puts "\n== Per-page SEO (§8) =="
PAGES.each do |f, name|
  next unless File.exist?(File.join(SITE, f))
  d = doc(f)
  check("#{name}: exactly one <h1>") { d.css("h1").length == 1 }
  check("#{name}: has <title>")      { d.at_css("title") && !d.at_css("title").text.strip.empty? }
  check("#{name}: meta description") { d.at_css('meta[name="description"]')&.[]("content").to_s.strip.length > 20 }
  check("#{name}: canonical URL")    { d.at_css('link[rel="canonical"]')&.[]("href").to_s.start_with?("http") }
  check("#{name}: og:image")         { d.at_css('meta[property="og:image"]')&.[]("content").to_s.include?("og-default") }
  check("#{name}: all <img> have non-empty alt (or aria-hidden)") do
    d.css("img").all? { |i| i["aria-hidden"] == "true" || i["alt"].to_s.strip.length.positive? || (i["alt"] && i["alt"] == "") && i["aria-hidden"] }
  end
end

# --- JSON-LD validity + required types (§9, §15) ----------------------------
puts "\n== JSON-LD (§9) =="
def ld_types(rel)
  doc(rel).css('script[type="application/ld+json"]').map do |s|
    JSON.parse(s.text)
  end
end

check("Home: valid JSON-LD present") { ld_types("index.html").any? }
check("Home: SoftwareApplication with offers price 0 + downloadUrl") do
  ld_types("index.html").any? do |j|
    j["@type"] == "SoftwareApplication" &&
      j.dig("offers", "price").to_s == "0" &&
      j["downloadUrl"].to_s.include?("releases") &&
      %w[Android Linux].all? { |os| j["operatingSystem"].to_s.include?(os) }
  end
end
check("FAQ: FAQPage JSON-LD parses and has questions") do
  ld_types("faq/index.html").any? do |j|
    j["@type"] == "FAQPage" && j["mainEntity"].is_a?(Array) && j["mainEntity"].length >= 10 &&
      j["mainEntity"].all? { |q| q["@type"] == "Question" && q.dig("acceptedAnswer", "text").to_s.length > 10 }
  end
end

# --- AEO: robots.txt + llms.txt (§9) ----------------------------------------
puts "\n== robots.txt / llms.txt (§9) =="
robots = read("robots.txt")
AI_CRAWLERS.each { |b| check("robots.txt names AI crawler #{b}") { robots.include?(b) } }
check("robots.txt references sitemap") { robots.match?(%r{Sitemap:\s*https?://\S+/sitemap\.xml}) }
check("robots.txt does not Disallow: /") { !robots.match?(/^Disallow:\s*\/\s*$/) }

llms = read("llms.txt")
check("llms.txt has H1 project name") { llms.match?(/^#\s+Darkian Studio/) }
check("llms.txt has blockquote summary") { llms.match?(/^>\s+\S/) }
check("llms.txt has H2 section(s) with links") { llms.match?(/^##\s+\S/) && llms.include?("](") }
check("llms.txt has Optional section") { llms.include?("## Optional") }

# --- Install command verbatim (§11, §15) ------------------------------------
puts "\n== Guardrails (§11) =="
install = read("install/index.html")
check("Install page contains README setup command verbatim") do
  install.include?(README_COMMAND)
end

# No private-repo implementation detail should leak (§11). These names are the
# app's public repo/docs vocabulary and ARE allowed; we instead scan for tokens
# that would only appear if private internals leaked in.
FORBIDDEN = ["BEGIN RSA", "PRIVATE KEY", "ghp_", "github_pat_", "AKIA"].freeze
puts "\n== Secret/leak scan (§11) =="
leaks = []
Dir.glob(File.join(SITE, "**", "*.{html,txt,xml,json}")).each do |path|
  body = File.read(path)
  FORBIDDEN.each do |tok|
    leaks << "#{tok} in #{path.sub(SITE + '/', '')}" if body.include?(tok)
  end
end
check("no forbidden secret tokens in output") { leaks.empty? }
leaks.each { |l| puts "    -> #{l}" }

# --- Report -----------------------------------------------------------------
puts "\n#{'-' * 48}"
if @failures.empty?
  puts "All site tests passed."
  exit 0
else
  puts "#{@failures.length} failure(s):"
  @failures.each { |f| puts "  - #{f}" }
  exit 1
end
