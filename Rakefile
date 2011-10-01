require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "rapper"
  gem.homepage = "http://tysontate.github.com/rapper/"
  gem.license = "MIT"
  gem.summary = %Q{Static asset packager and compressor with versioning and built-in view helpers.}
  gem.description = %Q{Static asset packager and compressor with versioning and built-in view helpers. Compresses files only when they need compressing.}
  gem.email = "tyson@tysontate.com"
  gem.authors = ["Tyson Tate"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new do |config|
  config.options = ["--private", "--protected"]
end
