require 'yaml'

module Rapper
  # Rapper configuration and definition methods.
  module Config
    
    attr_accessor :environment, :config, :definitions
    
    protected
    
    # Load the Rapper configuration from a YAML file and all asset definition
    # YAML files in the folder specified in the current environment's
    # <code>definition_root</code> setting. The definition type is inferred
    # from the file name. E.g. The type key for <code>javascript.yml</code>
    # will be "javascript".
    # 
    # @param [String] config_path The path to the configuration YAML file.
    def load_config( config_path )
      @config = YAML.load_file( config_path )
      if env_config.nil?
        raise Rapper::Errors::InvalidEnvironment,
          "The '#{@environment}' environment is not defined in #{config_path}"
      elsif env_config["definition_root"].nil?
        raise Rapper::Errors::NoDefinitionRoot,
          "No 'definition_root' has been defined for #{@environment}"
      end
      definition_paths = File.join( env_config["definition_root"], "*.yml" )
      Dir[definition_paths].each do |definition|
        type = File.basename( definition, ".yml" )
        @definitions[type] = Definition.new( definition )
      end
    end
    
    protected
    
    # Get the config setting for the given key.
    # 
    # @param [String] key Configuration key.
    # 
    # @return [String,Hash] If the current environment's config defines this
    #   setting, returns that value. If not, returns the default setting. If
    #   the default setting is a hash, returns the default merged with the
    #   environment's setting.
    def get_config( key )
      if default_config[key].is_a?( Hash )
        default_config[key].merge( env_config[key] || {} )
      else
        env_config.key?( key ) ? env_config[key] : default_config[key]
      end
    end
    
    # Update the asset definition files. (Typically done after regenerating
    # versions.)
    # 
    # @param [<String>] types Asset types to update the definition files for.
    #   Defaults to all types (i.e. every type with a definition file in
    #   `definition_root`).
    def update_definitions( *types )
      types = types.empty? ? asset_types : types
      log :info, "Updating definitions for #{types.join( ', ' )}"
      
      types.each do |type|
        @definitions[type].update
      end
    end
    
    private
    
    # @return [Hash] Default rapper configuration.
    def default_config
      {
        "bundle" => true,
        "compress" => true,
        "tag_style" => "html5",
        "version" => true,
        "yui_compressor" => {
          "line_break" => 2000
        }
      }
    end
    
    # @return [Hash] The configuration for the currently set environment.
    def env_config
      @config[@environment]
    end
    
    # @return [Array<String>] All defined asset types.
    def asset_types
      @definitions.keys
    end
    
  end
end
