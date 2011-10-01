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
  gem.name = "rapper_lite"
  gem.homepage = "http://github.com/tysontate/rapper_lite/"
  gem.license = "MIT"
  gem.summary = %Q{Simple static asset packaging.}
  gem.description = %Q{Simple static asset packaging. Compresses files only when they're updated.}
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
