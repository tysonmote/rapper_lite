$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec'
require 'rapper'
require 'fileutils'

Spec::Runner.configure do |config|
  config.before :suite do
    `mkdir tmp/` unless FileTest::directory?( "tmp" )
  end
  
  # Tear down test case assets folders
  config.after :each do
    FileUtils.rm_r( Dir[ "tmp/*" ] )
    FileUtils.rm_r( Dir[ "spec/fixtures/*/assets" ] )
  end
end

def file_names( path )
  Dir[path].map do |path|
    File.basename( path )
  end
end

# Adapted from: https://github.com/wycats/ruby_decorators/blob/master/specs.rb

Spec::Matchers.define :have_stdout do |regex|
  regex = /^#{Regexp.escape(regex)}$/ if regex.is_a?(String)
  
  match do |proc|
    $stdout = StringIO.new
    proc.call
    $stdout.rewind
    @captured = $stdout.read
    
    $stdout = STDOUT
    @captured =~ regex
  end
  
  failure_message do |proc|
    "Expected #{regex.inspect} but got #{@captured.inspect}"
  end
  
  failure_message do |proc|
    "Expected #{@captured.inspect} not to match #{regex.inspect}"
  end
end

# https://github.com/wycats/ruby_decorators/blob/master/specs.rb
module Kernel
  def silence_stdout
    $stdout = StringIO.new
    yield
    $stdout = STDOUT
  end
end
