module RapperLite
  
  # Rake tasks for building / refreshing packages
  class Tasks
    
    # Set up rapper asset packaging Rake tasks.
    # 
    # @param [Symbol] namespace The Rake namespace to put the generated
    # tasks under.
    # 
    # @yield [config] Configuration hash. `:path` should be the path to the
    # configuration YAML file. `:env` is the optional environment. Defaults to
    # `:production`.
    def initialize( namespace = :rapper, &block )
      @namespace = namespace
      @config = {
        :path => "rapper.yml"
      }
      yield @config
      @rapper = RapperLite::Engine.new( @config[:path] )
      self.define
    end
    
    private
    
    # Creates all rapper rake tasks: package all assets, package assets for
    # each type.
    def define
      namespace @namespace do
        desc "Package static assets that need re-packaging"
        task :package do
          @rapper.package
        end
        
        desc "Watch static assets and re-package when necessary"
        task :watch do
          begin
            RapperLite::Engine.method( :watch )
          rescue NameError
            raise "You need to `require 'rapper_lite/watch_support'`, first."
          end
          @rapper.watch
        end
      end
    end
  end
end
