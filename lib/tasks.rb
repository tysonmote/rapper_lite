module Rapper
  
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
      @config = {}
      yield @config
      @config[:env] ||= :production
      @rapper = Rapper::Engine.new( @config[:path], @config[:env] )
      define
    end
    
    private
    
    # Creates all rapper rake tasks: package all assets, package assets for
    # each type.
    def define
      namespace @namespace do
        desc "Package all assets that need re-packaging"
        task :package do
          @rapper.package
        end
        
        namespace :package do
          @rapper.definitions.each do |type, definition|
            desc "Package all #{type} assets that need re-packaging"
            task type do
              @rapper.package( type )
            end
          end
        end
      end
    end
  end
end
