# Rapper-wide utility methods for working with paths, files, etc.
module RapperLite::Utils
  
  protected
  
  # Concatenate one or more files. Uses <code>cat</code>.
  # 
  # @param [Array<String>,String] source_files A  path or array of paths to
  # files to concatenate.
  # 
  # @param [String] destination_file Destination for concatenated output.
  def join_files( source_files, destination_file )
    source_files = Array( source_files )
    source_files.any? do |path|
      raise "#{path} doesn't exist." unless File.exists?( path )
    end
    system "cat #{source_files.join( " " )} > #{destination_file}"
  end

  def config_key?( key )
    %w( root destination ).include?( key )
  end
end

