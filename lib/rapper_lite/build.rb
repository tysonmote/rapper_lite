require "coffee-script"
require "sass"

module RapperLite::Build
  
  def build_package( type, name )
    source_paths = self.file_paths( type, name )
    destination_file = self.destination_path( type, name )
    tempfiles = []
    
    source_paths.map! do |source_path|
      tempfile, path = self.process( source_path )
      # Keep reference so GC doesn't unlink file
      tempfiles << tempfile if tempfile
      path
    end
    
    # Join files and compress if needed
    self.join_files( source_paths, destination_file )
    self.compress( destination_file ) if self.compress?( type )
    
    # Cleanup
    tempfiles.each{ |tempfile| tempfile.unlink }
  end
  
  protected
  
  # Returns tuple: [nil or Tempfile, path to file]
  def process( source_path )
    tempfile = nil
    path = source_path
    
    if engine = self.conversion_engine( source_path )
      tempfile = Tempfile.new( "rapper_lite_source" )
      if engine == Sass
        tempfile.write( engine.compile( File.read( source_path ), :syntax => :sass ) )
      else
        tempfile.write( engine.compile( File.read( source_path ) ) )
      end
      tempfile.close
      path = tempfile.path
    end
    
    [tempfile, path]
  end
  
  def conversion_engine( source_path )
    {
      ".sass" => Sass,
      ".coffee" => CoffeeScript
    }[File.extname( source_path )]
  end
  
end
