module RapperLite
  class Engine
    
    def watch
      rapper = self
      rapper.noisy_package
      FSSM.monitor( rapper.common_root, '**/*.{css,js,coffee}' ) do
        component_files = rapper.all_component_paths
        update do |base, relative|
          if component_files.include?( File.join( base, relative) )
            rapper.noisy_package
          end
        end
      end
    end
    
    def noisy_package
      print( "Compiling static assets..." ) && STDOUT.flush
      self.package
      puts " Done!"
    end
    
    # LCD for JS and CSS roots
    def common_root
      js_path = File.expand_path( self.root( :js ) ).split( "/" )
      css_path = File.expand_path( self.root( :css ) ).split( "/" )
      path = []
      while js_component = js_path.shift && css_component = css_path.shift
        break if js_component != css_component
        path << js_component
      end
      path.join( "/" )
    end
    
    # All absolute file paths for the component files
    def all_component_paths
      [:css, :js].map do |type|
        (@definitions[type].keys - self.config_keys).map do |name|
          self.file_paths( type, name )
        end
      end.flatten.uniq.map do |path|
        File.expand_path( path )
      end
    end
  end
end
