require "coffee-script"

module RapperLite::Build
  
  def build_package( type, name )
    source_paths = self.file_paths( type, name )
    destination_file = self.destination_path( type, name )
    tempfiles = []
    
    # Convert any CoffeeScript to JS
    if type == :js
      source_paths.map! do |source_path|
        if File.extname( source_path ) == ".coffee"
          tempfile = Tempfile.new( "rapper_lite_coffee" )
          tempfile.write( CoffeeScript.compile( File.read( source_path ) ) )
          tempfile.close
          tempfile.path
        else
          source_path
        end
      end
    end
    
    # Join files and compress if needed
    self.join_files( source_paths, destination_file )
    self.compress( destination_file ) if self.compress?( type )
    
    # Cleanup
    tempfiles.each{ |tempfile| tempfile.unlink }
  end
end
