require 'digest/md5'
require 'tempfile'

# Asset versioning methods.
module RapperLite::Versioning
  
  def needs_packaging?( type, name )
    return true unless File.exists?( self.destination_path( type, name ) )
    self.version( type, name ) != @definitions[type][name]["version"]
  end
  
  protected
  
  # MD5 version of the concatenated raw asset package.
  def version( type, name )
    source_paths = self.file_paths( type, name )
    destination_file = Tempfile.new( 'rapper' )
    self.join_files( source_paths, destination_file.path )
    version = Digest::MD5.file( destination_file.path ).to_s[0,7]
    destination_file.unlink
    version
  end
  
  def refresh_versions
    [:css, :js].each do |type|
      @definitions[type].each do |name, spec|
        next if self.config_key?( name )
        @definitions[type][name]["version"] = self.version( type, name )
      end
    end
  end
end
