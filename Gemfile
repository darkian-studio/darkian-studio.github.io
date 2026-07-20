source "https://rubygems.org"

# GitHub Pages builds this site natively — no Actions workflow needed for v1.
# The github-pages gem pins Jekyll and every plugin to the exact versions
# GitHub Pages runs in production, so local builds match the live site.
gem "github-pages", group: :jekyll_plugins

# Plugins are also declared in _config.yml's `plugins:` array, which is what
# GitHub Pages actually reads (it ignores plugins listed only in the Gemfile).
group :jekyll_plugins do
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
  gem "jekyll-feed"
end

# Windows/JRuby time zone data (harmless elsewhere).
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# CI-only: link/image/HTML checking of the built _site.
group :test do
  gem "html-proofer", "~> 5.0"
  gem "nokogiri", "~> 1.16"
end
