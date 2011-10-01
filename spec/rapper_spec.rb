require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rapper do
  describe "setup" do
    it "loads configuration and environment" do
      lambda do
        Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      end.should_not raise_error
    end
    
    it "bombs out if given a bad configuration file" do
      lambda do
        Rapper::Engine.new( "spec/fixtures/config/fake.yml", "test" )
      end.should raise_error( Errno::ENOENT )
    end
    
    it "bombs out if given an invalid environment" do
      lambda do
        Rapper::Engine.new( "spec/fixtures/config/assets.yml", "error" )
      end.should raise_error( Rapper::Errors::InvalidEnvironment )
    end
    
    it "bombs out if no definition_root setting is provided" do
      lambda do
        Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_no_definition_root" )
      end.should raise_error( Rapper::Errors::NoDefinitionRoot )
    end
    
    it "uses the given environment's specific config" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      rapper.environment.should == "test"
      # private
      rapper.send( :env_config )["bundle"].should be_true
      rapper.send( :env_config )["compress"].should be_true
      rapper.send( :env_config )["version"].should be_false
    end
    
    it "uses default config when environment config isn't set for the setting" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_empty" )
      # private
      rapper.send( :get_config, "bundle" ).should be_true
      rapper.send( :get_config, "compress" ).should be_true
      rapper.send( :get_config, "version" ).should be_true
      rapper.send( :get_config, "yui_compressor" ).should == {
        "line_break" => 2000
      }
    end
    
    it "loads asset definitions" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      rapper.send( :asset_types ).sort.should == ["javascripts", "stylesheets"]
      rapper.definitions["javascripts"].should be_a( Rapper::Definition )
      rapper.definitions["stylesheets"].should be_a( Rapper::Definition )
      rapper.definitions["javascripts"].root.should == "spec/fixtures/javascripts"
      rapper.definitions["javascripts"].component_tag_root.should == "/javascripts"
      rapper.definitions["javascripts"].asset_tag_root.should == "/javascripts/assets"
      rapper.definitions["javascripts"].suffix.should == "js"
      rapper.definitions["javascripts"].assets.should be_a( YAML::Omap )
      rapper.definitions["javascripts"].assets.should == {
        "single_file" => {
          "files" => ["simple_1"],
          "version" => "98bc"
        },
        "multiple_files" => {
          "files" => ["simple_1", "subfolder/simple_2"],
          "version" => "f3d9"
        }
      }
    end
  end
  
  describe "logging" do
    it "is off by default" do
      lambda do
        Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_empty" )
      end.should_not have_stdout( /./ )
    end
    
    it "can log to stdout" do
      lambda do
        rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_logging_stdout" )
        rapper.send( :log, :info, "Derp" )
      end.should have_stdout( "Derp" )
    end
    
    it "doesn't log verbose messages unless configured" do
      lambda do
        rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_logging_stdout" )
        rapper.send( :log, :verbose, "Derp" )
      end.should_not have_stdout( "Derp" )
    end
    
    it "logs verbose messages if configured" do
      lambda do
        rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_logging_verbose" )
        rapper.send( :log, :verbose, "Derp" )
      end.should have_stdout( "Derp" )
    end
    
    it "can log to a file" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_logging_file" )
      rapper.send( :log, :info, "Derp" )
      File.read( "tmp/test_logging_file.log" ).should == "Derp\n"
    end
  end
  
  describe "versioning" do
    it "uses the concatenated file to calculate versions" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      rapper.send( :refresh_versions )
      rapper.definitions["javascripts"].assets["single_file"].should == {
        "files" => ["simple_1"],
        "version" => "98bc"
      }
      rapper.definitions["javascripts"].assets["multiple_files"].should == {
        "files" => ["simple_1", "subfolder/simple_2"],
        "version" => "f3d9"
      }
    end
    
    it "doesn't re-package assets that don't need re-packaging" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      rapper.package
      
      rapper.should_not_receive( :compress )
      rapper.package
    end
  end
  
  describe "custom definition destination" do
    before :each do
      @rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_custom_destination" )
      @rapper.package
    end
    
    it "works" do
      Dir[ "tmp/custom_destination/*" ].should == ["tmp/custom_destination/multiple_files.js"]
    end
    
    it "uses the asset tag root" do
      @rapper.js_tag( "javascripts", "multiple_files" ).should ==
        "<script src=\"/javascripts/compiled/multiple_files.js?v=f3d9\"></script>"
    end
  end
  
  describe "custom definition destination, without bundling" do
    before :each do
      @rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_custom_destination_no_bundle" )
      @rapper.package
    end
    
    it "works" do
      Dir[ "tmp/custom_destination/*" ].should == ["tmp/custom_destination/multiple_files.js"]
    end
    
    it "doesn't use the defaut '/assets' tag root" do
      @rapper.js_tag( "javascripts", "multiple_files" ).should ==
        "<script src=\"/javascripts/components/simple_1.js?v=f3d9\"></script>\n<script src=\"/javascripts/components/subfolder/simple_2.js?v=f3d9\"></script>"
    end
  end
  
  describe "misc. methods" do
    it "provides tag files and paths" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_tag_paths" )
      rapper.tag_paths( "javascripts", "multiple_files" ).should ==
        ["/javascripts/assets/multiple_files.js?v=f3d9"]
      
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_tag_paths_no_bundle" )
      rapper.tag_paths( "javascripts", "multiple_files" ).should ==
        ["/javascripts/simple_1.js?v=f3d9", "/javascripts/subfolder/simple_2.js?v=f3d9"]
    end
  end
  
  describe "packaging test cases" do
    Dir["spec/fixtures/test_cases/*"].each do |folder|
      next unless File.directory?( folder )
      name = folder.split( "/" ).last
      
      paths = [
        {
          :results => "spec/fixtures/javascripts/assets/*.*",
          :expecteds => "#{folder}/expected/javascripts/*.*",
        },
        {
          :results => "spec/fixtures/stylesheets/assets/*.*",
          :expecteds => "#{folder}/expected/stylesheets/*.*",
        }
      ]
      
      it "passes the \"#{name}\" test case" do
        rapper = Rapper::Engine.new( "#{folder}/assets.yml", "test" )
        rapper.package
        
        paths.each do |path|
          # Produces the same exact individual files
          file_names( path[:results] ).should == file_names( path[:expecteds] )
          # Contents are all the same
          results = Dir[ path[:results] ]
          expecteds = Dir[ path[:expecteds] ]
          
          results.each_index do |i|
            unless File.read( results[i] ) == File.read( expecteds[i] )
              raise "#{results[i]} did not match #{expecteds[i]}"
            end
          end
        end
      end
    end
  end
  
  describe "bundling" do
    it "raises an error if a file doesn't exist" do
      rapper = Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_missing_file" )
      
      lambda do
        rapper.package
      end.should raise_error( Rapper::Errors::MissingComponentFile )
    end
  end
  
  describe "view helpers" do
    
    module Merb; class Controller; end; end
    
    before :each do
      @controller = Merb::Controller.new
    end
    
    it "returns tags for component files when bundling is off" do
      Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test_no_bundle" )
      @controller.include_stylesheets( :single_file ).should ==
        "<link rel=\"stylesheet\" href=\"/stylesheets/simple_1.css\">"
      @controller.include_stylesheets( :multiple_files ).should ==
        "<link rel=\"stylesheet\" href=\"/stylesheets/simple_1.css\">\n<link rel=\"stylesheet\" href=\"/stylesheets/simple_2.css\">"
      @controller.include_javascripts( :single_file ).should ==
        "<script src=\"/javascripts/simple_1.js\"></script>"
      @controller.include_javascripts( :multiple_files ).should ==
        "<script src=\"/javascripts/simple_1.js\"></script>\n<script src=\"/javascripts/subfolder/simple_2.js\"></script>"
    end
    
    it "returns tags for asset when bundling is on" do
      Rapper::Engine.new( "spec/fixtures/config/assets.yml", "test" )
      @controller.include_stylesheets( :single_file ).should ==
        "<link type=\"text/css\" rel=\"stylesheet\" href=\"/stylesheets/assets/single_file.css\">"
      @controller.include_stylesheets( :multiple_files ).should ==
        "<link type=\"text/css\" rel=\"stylesheet\" href=\"/stylesheets/assets/multiple_files.css\">"
      @controller.include_javascripts( :single_file ).should ==
        "<script type=\"text/javascript\" src=\"/javascripts/assets/single_file.js\"></script>"
      @controller.include_javascripts( :multiple_files ).should ==
        "<script type=\"text/javascript\" src=\"/javascripts/assets/multiple_files.js\"></script>"
    end
    
    it "can return xhtml tags" do
      Rapper::Engine.new( "spec/fixtures/config/assets.yml", "xhtml_tags" )
      @controller.include_stylesheets( :single_file ).should ==
        "<link type=\"text/css\" rel=\"stylesheet\" href=\"/stylesheets/assets/single_file.css\" />"
      @controller.include_stylesheets( :multiple_files ).should ==
        "<link type=\"text/css\" rel=\"stylesheet\" href=\"/stylesheets/assets/multiple_files.css\" />"
      @controller.include_javascripts( :single_file ).should ==
        "<script type=\"text/javascript\" src=\"/javascripts/assets/single_file.js\"></script>"
      @controller.include_javascripts( :multiple_files ).should ==
        "<script type=\"text/javascript\" src=\"/javascripts/assets/multiple_files.js\"></script>"
    end
    
    it "can return html5 tags" do
      Rapper::Engine.new( "spec/fixtures/config/assets.yml", "html5_tags" )
      @controller.include_stylesheets( :single_file ).should ==
        "<link rel=\"stylesheet\" href=\"/stylesheets/assets/single_file.css\">"
      @controller.include_stylesheets( :multiple_files ).should ==
        "<link rel=\"stylesheet\" href=\"/stylesheets/assets/multiple_files.css\">"
      @controller.include_javascripts( :single_file ).should ==
        "<script src=\"/javascripts/assets/single_file.js\"></script>"
      @controller.include_javascripts( :multiple_files ).should ==
        "<script src=\"/javascripts/assets/multiple_files.js\"></script>"
    end
    
    it "adds a version number if versioning is on" do
      Rapper::Engine.new( "spec/fixtures/config/assets.yml", "versions" )
      @controller.include_stylesheets( :single_file ).should ==
        "<link rel=\"stylesheet\" href=\"/stylesheets/assets/single_file.css?v=1e17\">"
      @controller.include_javascripts( :single_file ).should ==
        "<script src=\"/javascripts/assets/single_file.js?v=98bc\"></script>"
    end
  end
end
