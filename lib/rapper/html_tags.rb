require 'erb'

module Rapper
  # HTML tag generators.
  module HtmlTags
    
    # @param [Symbol] type Definition type.
    # 
    # @return [Symbol] Tag type for the given definition type. One of `:css_tag`
    # or `:js_tag`
    def tag_method_for_type( type )
      if @definitions[type].suffix =~ /css/
        :css_tag
      else
        :js_tag
      end
    end
    
    # Build a JS tag for an asset.
    #
    # @param [Symbol] type Definition type.
    # 
    # @param [Symbol] name Name of the asset to build a `<script>` tag for.
    # 
    # @return [String] A `<script>` tag for the given asset in the configured
    # HTML style.
    def js_tag( type, name )
      self.get_tag( JsTag, type, name )
    end
    
    # Build a CSS tag for an asset.
    # 
    # @param [Symbol] type Definition type.
    # 
    # @param [Symbol] name Name of the asset to build a `<link>` tag for.
    # 
    # @return [String] A `<link>` tag for the given asset in the configured
    # HTML style.
    def css_tag( type, name )
      self.get_tag( CssTag, type, name )
    end
    
    # Same as `tag_files`, but includes version query string if needed.
    def tag_paths( type, name )
      definition = @definitions[type]
      if self.get_config( 'version' )
        version = definition.get_version( name )
        tag_files( type, name ).map{|path| "#{path}?v=#{version}"}
      else
        tag_files( type, name )
      end
    end
    
    protected
    
    # Get all paths for a given asset. If bundling is turned on, a one-item
    # array is returned containing the path to the asset file. Otherwise, an
    # array of all component paths for the asset are returned.
    # 
    # @param [Symbol] type Definition type.
    # 
    # @param [Symbol] name Name of the asset to get paths for.
    # 
    # @return [String<Array>] All files that comprise the given asset.
    def tag_files( type, name )
      definition = @definitions[type]
      if self.get_config( "bundle" )
        Array( definition.asset_path( name, definition.asset_tag_root ) )
      else
        definition.component_paths( name, definition.component_tag_root )
      end
    end
    
    # Get the HTML for an asset.
    # 
    # @param [Rapper::HtmlTags::Tag] klass The HTML generator class to use.
    # 
    # @param [String] type Asset type.
    # 
    # @param [String] name Asset name.
    def get_tag( klass, type, name )
      definition = @definitions[type]
      style = self.get_config( 'tag_style' ).to_sym
      version = nil
      if self.get_config( 'version' )
        version = definition.get_version( name )
      end
      
      tag_files( type, name ).map do |path|
        klass.send( :for, path, version, style )
      end.join( "\n" )
    end
    
    # Represents an HTML tag.
    class Tag
      class << self
        
        # @return [Hash] A mapping of HTML styles to their appropriate HTML
        # tag template strings.
        def templates
          { :html => '', :html5 => '', :xhtml => '' }
        end
        
        # Build an HTML tag for a given resource in a given HTML style.
        # 
        # @param [String] path Publically accessible path to the asset file.
        # 
        # @param [String,nil] version Version string to append as a query
        # string.
        # 
        # @param [Symbol] style HTML tag style. One of `:html`, `:html5`, or
        # `:xhtml`.
        # 
        # @return [String] The appropriate HTML tag to include the resource.
        def for( path, version, style )
          @cache ||= {}
          @cache[style] ||= {}
          
          if version
            path << "?v=#{version}"
          end
          
          unless @cache[style][path] && @cache[style][path]
            @cache[style][path] = ERB.new( templates[style] ).result( binding )
          end
          
          @cache[style][path]
        end
      end
    end
    
    # JavaScript tag.
    class JsTag < Tag
      class << self
        def templates
          {
            :html => '<script type="text/javascript" src="<%= path %>"></script>',
            :html5 => "<script src=\"<%= path %>\"></script>",
            :xhtml => '<script type="text/javascript" src="<%= path %>"></script>'
          }
        end
      end
    end
    
    # CSS tag.
    class CssTag < Tag
      class << self
        def templates
          {
            :html => '<link type="text/css" rel="stylesheet" href="<%= path %>">',
            :html5 => "<link rel=\"stylesheet\" href=\"<%= path %>\">",
            :xhtml => '<link type="text/css" rel="stylesheet" href="<%= path %>" />'
          }
        end
      end
    end
  end
end
