source "https://rubygems.org"

ruby "3.1.2"

gem "fastlane", "~>2.220"
gem "jazzy", "~>0.14.4"
gem "nokogiri"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
