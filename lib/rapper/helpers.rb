module Rapper
  # Helpers for setting up view helpers.
  module HelperSetup
    
    # Loads view helpers for any/all available web frameworks available.
    # TODO: Clean up.
    def setup_helpers
      if Rapper::ViewHelpers.const_defined?( :RAPPER )
        Rapper::ViewHelpers.send( :remove_const, :RAPPER )
      end
      Rapper::ViewHelpers.const_set( :RAPPER, self )
      
      # Merb
      begin
        Merb::Controller.send( :include, Rapper::ViewHelpers )
      rescue NameError; end
    end
    
    private
  end
  
  # View helpers.
  module ViewHelpers
    RAPPER = nil
    
    def self.included( klass )
      klass.class_eval do
        # Define a "include_FOO" method for each definition type. For example,
        # if you have "stylesheets" and "javascripts" definitions, you'll have
        # "include_stylesheets( name )" and "include_javascripts( name )"
        # methods.
        RAPPER.definitions.each do |type, definition|
          tag_method = RAPPER.tag_method_for_type( type )
          define_method "include_#{type}".to_sym do |name|
            RAPPER.send( tag_method, type, name )
          end
        end
      end
    end
  end
end
