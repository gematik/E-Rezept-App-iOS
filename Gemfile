source "https://rubygems.org"

ruby "4.0.3"

gem "fastlane", "~>2.220"
gem "nokogiri", ">= 1.16.5"
gem "kramdown"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
