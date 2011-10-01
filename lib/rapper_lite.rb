require 'yaml'

module RapperLite; end
Dir[File.expand_path( "#{File.dirname( __FILE__ )}/rapper_lite/*.rb" )].each do |file|
  require file
end
# TODO: Re-enable
# require File.dirname( __FILE__ ) + "/tasks.rb"

# No batteries included, and no strings attached /
# No holds barred, no time for move fakin' /
# Gots to get the loot so I can bring home the bacon
module RapperLite
  class Engine
    include RapperLite::Config
    include RapperLite::Utils
    include RapperLite::Compressors
    include RapperLite::Versioning
    
    def initialize( config_path )
      @config = {}
      @definitions = Struct.new( :css, :js ).new
      self.load_config( config_path )
    end
    
    def package
      [:js, :css].each do |type|
        definition = @definitions[type]
        source = File.expand_path( self.root( type ) )
        
        definition.each do |name, spec|
          next if name == "root" || name == "destination"
          next unless self.needs_packaging?( type, name )
          
          source_files = self.file_paths( type, name )
          destination_file = self.destination_path( type, name )
          
          self.join_files( source_files, destination_file )
          
          if self.compress?
            self.compress( destination_file )
          end
        end
      end
      
      self.refresh_versions
      self.save_config
    end
  end
end
