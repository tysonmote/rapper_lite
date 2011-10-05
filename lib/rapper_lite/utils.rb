module RapperLite::Utils

  protected

  # Concatenate one or more files by shelling out to `cat`.
  def join_files( source_paths, destination_path )
    source_paths = Array( source_paths )
    source_paths.each do |path|
      raise "#{path} doesn't exist." unless File.exists?( path )
    end
    
    system "cat #{source_paths.join( " " )} > #{destination_path}"
  end

  # True if the given string is a reserved config key name.
  def config_key?( key )
    self.config_keys.include?( key )
  end
  
  def config_keys
    %w( root destination compress )
  end
end
