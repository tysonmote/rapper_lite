require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RapperLite do
  Dir["spec/fixtures/testcases/*/"].each do |folder|
    name = File.basename( folder )
    
    paths = [
      {
        :results => "tmp/*.js",
        :expecteds => "#{folder}expected/*.js",
      },
      {
        :results => "tmp/*.css",
        :expecteds => "#{folder}expected/*.css",
      }
    ]
    
    it "passes the \"#{name}\" test case" do
      rapper = RapperLite::Engine.new( "#{folder}/rapper.yml" )
      rapper.package
      
      paths.each do |path|
        # Produces the same exact individual files
        file_names( path[:results] ).should == file_names( path[:expecteds] )
        
        # Contents are all the same
        results = Dir[ path[:results] ]
        expecteds = Dir[ path[:expecteds] ]
        
        results.each_index do |i|
          unless File.read( results[i] ) == File.read( expecteds[i] )
            puts
            puts File.read( results[i] )
            puts
            raise "#{results[i]} did not match #{expecteds[i]}"
          end
        end
      end
    end
  end
end
