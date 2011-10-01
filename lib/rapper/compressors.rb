require File.expand_path( File.dirname( __FILE__ ) + "/../yui/css_compressor.rb" )
require 'fileutils'
begin
  require "yui/compressor"
rescue LoadError; end

module Rapper
  # Compression handlers for various types of assets. And by "various" I mean
  # JavaScript and CSS.
  module Compressors
    
    # Compress a file in-place. Relies on the file's suffix to determine type.
    # 
    # @param [String] file Path to the file to compress.
    def compress( file )
      opts = {}
      # TODO: Someday this goes away.
      opts = get_config( "yui_compressor" ) if file =~ /\.js/
      Rapper::Compressors::Compressor.compress( file, opts )
    end
    
    protected
    
    # Base class for a compression handler.
    class Compressor
      class << self
        
        # Compress a file. Raises UnknownFileExtension if it doesn't know how
        # to compress a file with the given file's file extension.
        # 
        # @param [String] file_path Path to the file to compress.
        # 
        # @param [Hash] opts Options to be passed to the compressor (optional).
        def compress( file_path, opts={} )
          unless compressor = @extensions[File.extname( file_path )]
            raise Rapper::Errors::UnknownFileExtension,
              "Rapper doesn't know how to compress #{file_path}"
          end
          
          compressor.do_compress( file_path, opts )
        end
        
        protected
        
        attr_accessor :extensions
        
        # Register `self` as a file compressor.
        # 
        # @param [String] extension The file extension `self` handles.
        def register( extension )
          superclass.extensions ||= {}
          superclass.extensions[extension] = self
        end
        
        # Compress a file.
        # 
        # @param [String] file_path Path to the file to compress.
        def do_compress( file_path )
          raise NotImplementedError
        end
        
        # @param [String] file_path Path to a file.
        # 
        # @return [String] The contents of the file.
        def read_file( file_path )
          File.new( file_path, 'r' ).read
        end
        
        # @param [String] file_path Path to the desired file.
        # 
        # @return [File] Writable file instance with 0644 permissions.
        def writable_file( file_path )
          File.new( file_path, 'w', 0644 )
        end
      end
    end
    
    # Use Richard Hulse's Ruby port of the YUI CSS Compressor to compress the
    # contents of a CSS file.
    class CSSCompressor < Compressor
      register ".css"
      
      def self.do_compress( file_path, opts={} )
        return unless compressor_available?
        
        css = read_file( file_path )
        css = YUI::CSS.compress( css )
        destination = writable_file( file_path )
        
        destination.write( css )
        destination.write "\n"
        destination.close
      end
      
      def self.compressor_available?
        YUI::CSS.is_a?( Class )
      rescue NameError
        false
      end
    end
    
    # Uses YUI Compressor (via Sam Stephenson's yui-compressor gem) to compress
    # JavaScrpt.
    class JSCompressor < Compressor
      register ".js"
      
      def self.do_compress( file_path, opts={} )
        return unless compressor_available?
        
        compressor = YUI::JavaScriptCompressor.new( opts )
        
        js = read_file( file_path )
        destination = writable_file( file_path )
        
        destination.write( compressor.compress( js ) )
        destination.write "\n"
        destination.close
      end
      
      def self.compressor_available?
        YUI::JavaScriptCompressor.is_a?( Class )
      rescue NameError
        false
      end
    end
    
  end
end