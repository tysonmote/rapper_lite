$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec'
require 'rapper_lite'
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
