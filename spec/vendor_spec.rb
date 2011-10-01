require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe YUI::JavaScriptCompressor do
  it "shoud be available" do
    yui = YUI::JavaScriptCompressor.new
    yui.compress( "var x = 1; var y = 2;" ).should == "var x=1;var y=2;"
  end
end

describe YUI::CSS do
  # https://github.com/rhulse/ruby-css-toolkit/blob/master/test/yui_compressor_test.rb
  
  test_files = Dir[File.join( File.dirname( __FILE__ ), '/fixtures/yui_css/*.css' )]
  test_files.each_with_index do |file, i|
    test_css = File.read(file)
    expected_css = File.read( file + '.min' )
    test_name = File.basename( file, ".css" )
    
    it "passes the \"#{test_name}\" test case" do
      YUI::CSS.compress( test_css ).should == expected_css
    end
  end
end
