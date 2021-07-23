source "https://rubygems.org"

ruby "2.6.5"

gem "fastlane", "~>2.187"
gem "jazzy", "~>0.13"
gem "xcodeproj", "~>1.7"
gem "xcode-install", "~> 2.6.6"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
