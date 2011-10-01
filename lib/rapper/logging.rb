module Rapper
  # Basic logging support.
  module Logging
    
    protected
    
    # Guess if a string is a path.
    PATHY_STRING = /\.|\//
    
    # Outputs all arguments (joined with spaces) to:
    #   * <code>stdout</code> if "log" is set to "stdout" in the environment
    #     configuration.
    #   * a text file if "log" appears to be a file path (i.e. has a slash or
    #     period in it).
    # 
    # @param [Symbol] level Log level. :info or :verbose. :verbose level log
    # messages are only emitted if the "verbose_logging" setting is truthy.
    # 
    # @param [String] message Message to be logged.
    def log( level, message )
      return unless destination = get_config( "log" )
      return if !get_config( "log_verbose" ) && level == :verbose
      
      case destination
        when PATHY_STRING
          open( destination, "a" ) do |file|
            file.puts "#{message}\n"
          end
        when "stdout"
          puts message
      end
      
    end
    
  end
end
