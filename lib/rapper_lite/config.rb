module RapperLite::Config
  
  protected
  
  def load_config( config_path )
    @config_path = config_path
    @config = YAML.load_file( config_path )
    @definitions.css = @config["css"]
    @definitions.js = @config["js"]
  end
  
  def save_config
    File.open( @config_path, "w" ) do |file|
      file.puts @config.to_yaml
    end
  end
  
  def root( type )
    assert_type!( type )
    @definitions.send( type )["root"] || @config["root"] || "."
  end
  
  def destination( type )
    assert_type!( type )
    @definitions.send( type )["destination"] || @config["destination"] || "."
  end
  
  def compress?
    @config.key?( "compress" ) ? @config["compress"] : false
  end
  
  def yui_config
    @yui_config ||= {
      "line_break" => 2000,
      "munge" => false,
      "optimize" => true,
      "preserve_semicolons" => false
    }.merge( @config["yui_compressor"] || {} )
  end
  
  # Array of source files for the given asset package.
  def file_paths( type, name )
    definition = @definitions[type][name]
    root = self.root( type )
    definition["files"].map do |file|
      if file[0] == "+"
        self.file_paths( type, file[1..-1] )
      else
        File.join( root, "#{file}.#{type}" )
      end
    end.flatten
  end
  
  def destination_path( type, name )
    File.join( self.destination( type ), "#{name}.#{type}" )
  end
  
  def assert_type!( type )
    raise "wat." unless type == :css || type == :js
  end
end
