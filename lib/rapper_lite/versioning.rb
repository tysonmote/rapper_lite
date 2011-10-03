require 'digest/md5'
require 'tempfile'

# Asset versioning methods.
module RapperLite::Versioning
  
  protected
  
  def needs_packaging?( type, name )
    definition = @definitions[type][name]
    destination_file = self.destination_path( type, name )
    return true unless File.exists?( destination_file )
    
    current_version = definition["version"]
    new_version = self.version( type, name )
    new_version != current_version
  end
  
  def refresh_versions
    [:css, :js].each do |type|
      @definitions[type].each do |name, spec|
        next if self.config_key?( name )
        @definitions[type][name]["version"] = self.version( type, name )
      end
    end
  end
  
  # MD5 version of the concatenated asset package.
  def version( type, name )
    definition = @definitions[type][name]
    source_files = self.file_paths( type, name )
    destination_file = Tempfile.new( 'rapper' )
    self.join_files( source_files, destination_file.path )
    version = Digest::MD5.file( destination_file.path ).to_s[0,4]
    destination_file.unlink
    version
  end
end
