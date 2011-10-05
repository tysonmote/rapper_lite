require "rubygems"
require "bundler/setup"
require 'yaml'

module RapperLite; end
Dir[File.expand_path( "#{File.dirname( __FILE__ )}/rapper_lite/*.rb" )].each do |file|
  require file
end
# TODO: Re-enable?
# require File.dirname( __FILE__ ) + "/tasks.rb"

# No batteries included, and no strings attached /
# No holds barred, no time for move fakin' /
# Gots to get the loot so I can bring home the bacon
module RapperLite
  class Engine
    include RapperLite::Build
    include RapperLite::Compressors
    include RapperLite::Config
    include RapperLite::Utils
    include RapperLite::Versioning

    def initialize( config_path )
      self.load_config( config_path )
    end

    def package
      [:js, :css].each do |type|
        definition = @definitions[type]
        source = File.expand_path( self.root( type ) )
        
        definition.each do |name, spec|
          next if self.config_key?( name ) # Skip config settings
          next unless self.needs_packaging?( type, name )
          self.build_package( type, name )
        end
      end
      
      self.refresh_versions
      self.save_config
    end
  end
end

