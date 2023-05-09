# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rapper_lite"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tyson Tate"]
  s.date = "2011-10-10"
  s.description = "Simple static asset packaging. Compresses files only when they're updated."
  s.email = "tyson@tysontate.com"
  s.executables = ["rapper-lite", "rapper_lite"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "bin/rapper-lite",
    "bin/rapper_lite",
    "lib/rapper_lite.rb",
    "lib/rapper_lite/build.rb",
    "lib/rapper_lite/compressors.rb",
    "lib/rapper_lite/config.rb",
    "lib/rapper_lite/utils.rb",
    "lib/rapper_lite/versioning.rb",
    "lib/rapper_lite/watch_support.rb",
    "lib/tasks.rb",
    "lib/yui/css_compressor.rb",
    "rapper_lite.gemspec",
    "spec/fixtures/src/coffeescript.coffee",
    "spec/fixtures/src/simple_1.css",
    "spec/fixtures/src/simple_1.js",
    "spec/fixtures/src/simple_2.sass",
    "spec/fixtures/src/subfolder/simple_2.js",
    "spec/fixtures/testcases/combination/expected/base.css",
    "spec/fixtures/testcases/combination/expected/base.js",
    "spec/fixtures/testcases/combination/expected/base_combined.css",
    "spec/fixtures/testcases/combination/expected/base_combined.js",
    "spec/fixtures/testcases/combination/rapper.yml",
    "spec/fixtures/testcases/concatenation/expected/base.css",
    "spec/fixtures/testcases/concatenation/expected/base.js",
    "spec/fixtures/testcases/concatenation/expected/base_combined.css",
    "spec/fixtures/testcases/concatenation/expected/base_combined.js",
    "spec/fixtures/testcases/concatenation/rapper.yml",
    "spec/fixtures/yui_css/background-position.css",
    "spec/fixtures/yui_css/background-position.css.min",
    "spec/fixtures/yui_css/box-model-hack.css",
    "spec/fixtures/yui_css/box-model-hack.css.min",
    "spec/fixtures/yui_css/bug2527974.css",
    "spec/fixtures/yui_css/bug2527974.css.min",
    "spec/fixtures/yui_css/bug2527991.css",
    "spec/fixtures/yui_css/bug2527991.css.min",
    "spec/fixtures/yui_css/bug2527998.css",
    "spec/fixtures/yui_css/bug2527998.css.min",
    "spec/fixtures/yui_css/bug2528034.css",
    "spec/fixtures/yui_css/bug2528034.css.min",
    "spec/fixtures/yui_css/charset-media.css",
    "spec/fixtures/yui_css/charset-media.css.min",
    "spec/fixtures/yui_css/color.css",
    "spec/fixtures/yui_css/color.css.min",
    "spec/fixtures/yui_css/comment.css",
    "spec/fixtures/yui_css/comment.css.min",
    "spec/fixtures/yui_css/concat-charset.css",
    "spec/fixtures/yui_css/concat-charset.css.min",
    "spec/fixtures/yui_css/decimals.css",
    "spec/fixtures/yui_css/decimals.css.min",
    "spec/fixtures/yui_css/dollar-header.css",
    "spec/fixtures/yui_css/dollar-header.css.min",
    "spec/fixtures/yui_css/font-face.css",
    "spec/fixtures/yui_css/font-face.css.min",
    "spec/fixtures/yui_css/ie5mac.css",
    "spec/fixtures/yui_css/ie5mac.css.min",
    "spec/fixtures/yui_css/media-empty-class.css",
    "spec/fixtures/yui_css/media-empty-class.css.min",
    "spec/fixtures/yui_css/media-multi.css",
    "spec/fixtures/yui_css/media-multi.css.min",
    "spec/fixtures/yui_css/media-test.css",
    "spec/fixtures/yui_css/media-test.css.min",
    "spec/fixtures/yui_css/opacity-filter.css",
    "spec/fixtures/yui_css/opacity-filter.css.min",
    "spec/fixtures/yui_css/preserve-new-line.css",
    "spec/fixtures/yui_css/preserve-new-line.css.min",
    "spec/fixtures/yui_css/preserve-strings.css",
    "spec/fixtures/yui_css/preserve-strings.css.min",
    "spec/fixtures/yui_css/preserve_string.css",
    "spec/fixtures/yui_css/preserve_string.css.min",
    "spec/fixtures/yui_css/pseudo-first.css",
    "spec/fixtures/yui_css/pseudo-first.css.min",
    "spec/fixtures/yui_css/pseudo.css",
    "spec/fixtures/yui_css/pseudo.css.min",
    "spec/fixtures/yui_css/special-comments.css",
    "spec/fixtures/yui_css/special-comments.css.min",
    "spec/fixtures/yui_css/star-underscore-hacks.css",
    "spec/fixtures/yui_css/star-underscore-hacks.css.min",
    "spec/fixtures/yui_css/string-in-comment.css",
    "spec/fixtures/yui_css/string-in-comment.css.min",
    "spec/fixtures/yui_css/zeros.css",
    "spec/fixtures/yui_css/zeros.css.min",
    "spec/rapper_lite_spec.rb",
    "spec/spec_helper.rb",
    "spec/vendor_spec.rb"
  ]
  s.homepage = "http://github.com/tysontate/rapper_lite/"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Simple static asset packaging."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yui-compressor>, ["~> 0.9.6"])
      s.add_runtime_dependency(%q<fssm>, ["~> 0.2.7"])
      s.add_runtime_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_runtime_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_runtime_dependency(%q<sass>, ["~> 3.1.10"])
      s.add_development_dependency(%q<rake>, "= 12.3.3")
      s.add_development_dependency(%q<rspec>, ["~> 1.3.2"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<rdiscount>, ["~> 1.6.8"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
    else
      s.add_dependency(%q<yui-compressor>, ["~> 0.9.6"])
      s.add_dependency(%q<fssm>, ["~> 0.2.7"])
      s.add_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
      s.add_dependency(%q<sass>, ["~> 3.1.10"])
      s.add_dependency(%q<rake>, "= 12.3.3")
      s.add_dependency(%q<rspec>, ["~> 1.3.2"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<rdiscount>, ["~> 1.6.8"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    end
  else
    s.add_dependency(%q<yui-compressor>, ["~> 0.9.6"])
    s.add_dependency(%q<fssm>, ["~> 0.2.7"])
    s.add_dependency(%q<rb-fsevent>, [">= 0"])
    s.add_dependency(%q<coffee-script>, ["~> 2.2.0"])
    s.add_dependency(%q<sass>, ["~> 3.1.10"])
    s.add_dependency(%q<rake>, "= 12.3.3")
    s.add_dependency(%q<rspec>, ["~> 1.3.2"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<rdiscount>, ["~> 1.6.8"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
  end
end

