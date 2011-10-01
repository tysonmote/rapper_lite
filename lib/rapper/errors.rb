module Rapper
  # Common Rapper errors.
  module Errors
    
    # Raised when an invalid environment param is used. An invalid environment
    # is one not defined in the current rapper config.
    class InvalidEnvironment < StandardError; end
    
    # Raised when no "definition_root" setting is given for the current
    # environment.
    class NoDefinitionRoot < StandardError; end
    
    # Raised when an invalid asset name param is used. An invalid asset name
    # is one not defined in a given definition file.
    class InvalidAssetName < StandardError; end
    
    # Raised when attempting to compress a file with an extension that Rapper
    # doesn't recognize.
    class UnknownFileExtension < StandardError; end
    
    # Raised when an asset definition refers to a file that doesn't exist.
    class MissingComponentFile < StandardError; end
  end
end
