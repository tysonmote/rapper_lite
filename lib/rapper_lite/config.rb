module RapperLite::Config
  
  # Source path for files of the given type.
  def root( type )
    self.config_or_default( "root", type, "." )
  end
  
  # Destination path for files of the given type.
  def destination( type )
    self.config_or_default( "destination", type, "." )
  end
  
  # True if we should compress files of the given type.
  def compress?( type )
    self.config_or_default( "compress", type, false )
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
    @definitions[type][name]["files"].map do |file|
      if file[0] == "+"
        # Include other asset package
        self.file_paths( type, file[1..-1] )
      elsif type == :js
        coffee_path = File.join( self.root( type ), "#{file}.coffee" )
        js_path = File.join( self.root( type ), "#{file}.js" )
        File.exists?( coffee_path ) ? coffee_path : js_path
      else # CSS
        sass_path = File.join( self.root( type ), "#{file}.sass" )
        css_path = File.join( self.root( type ), "#{file}.css" )
        File.exists?( sass_path ) ? sass_path : css_path
      end
    end.flatten
  end
  
  def destination_path( type, name )
    File.join( self.destination( type ), "#{name}.#{type}" )
  end
  
  protected
  
  def load_config( config_path )
    @config_path = config_path
    @config = YAML.load_file( @config_path )
    @definitions = {
      :css => @config["css"],
      :js => @config["js"]
    }
  end
  
  # Write in-memory config to file (i.e. just update version strings).
  def save_config
    File.open( @config_path, "w" ) do |file|
      file.puts( @config.to_yaml )
    end
  end
  
  def config_or_default( key, type, default )
    if @definitions[type].key?( key )
      @definitions[type][key]
    else
      @config.key?( key ) ? @config[key] : default
    end
  end
end
