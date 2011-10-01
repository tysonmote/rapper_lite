# Source: https://github.com/rhulse/ruby-css-toolkit
# 
# Only minor modifications to module structure, code style, and comments have
# been made.
# 
# Original license:
# =================
# 
# Ruby CSS Compressor Copyright License Agreement (BSD License)
# 
# Copyright (c) 2010, Richard Hulse
# All rights reserved.
# 
# YUI CSS files in the test suite are Copyright (c) 2009, Yahoo! Inc. All rights reserved.
# 
# Redistribution and use of this software in source and binary forms,
# with or without modification, are permitted provided that the following
# conditions are met:
# 
# * Redistributions of source code must retain the above
#   copyright notice, this list of conditions and the
#   following disclaimer.
# 
# * Redistributions in binary form must reproduce the above
#   copyright notice, this list of conditions and the
#   following disclaimer in the documentation and/or other
#   materials provided with the distribution.
# 
# * Neither the name of Yahoo! Inc. nor the names of its
#   contributors may be used to endorse or promote products
#   derived from this software without specific prior
#   written permission of Yahoo! Inc.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module YUI
  # Methods for working with CSS.
  class CSS
    
    class << self
      
      attr_reader :input_size, :output_size
      
      # Compress CSS using the Ruby port of the YUI Compressor (by
      # <a href="https://github.com/rhulse">Richard Hulse</a>).
      # 
      # @param [String] css The CSS to be compressed.
      # 
      # @param [Integer] line_length (optional) Number of columns to wrap to.
      #   Default is no wrapping.
      # 
      # @return [String] Compressed CSS.
      def compress(css, line_length=0)
        @preservedTokens = []
        @comments = []
        @output_size = 0
        @input_size = css.length
        
        css = process_comments_and_strings(css)
        
        # Normalize all whitespace strings to single spaces. Easier to work with that way.
        css.gsub!(/\s+/, ' ')
        
        # Remove the spaces before the things that should not have spaces before them.
        # But, be careful not to turn "p :link {...}" into "p:link{...}"
        # Swap out any pseudo-class colons with the token, and then swap back.
        css.gsub!(/(?:^|\})[^\{:]+\s+:+[^\{]*\{/) do |match|
          match.gsub(':', '___PSEUDOCLASSCOLON___')
        end
        css.gsub!(/\s+([!\{\};:>+\(\)\],])/, '\1')
        css.gsub!(/([!\{\}:;>+\(\[,])\s+/, '\1')
        css.gsub!('___PSEUDOCLASSCOLON___', ':')
        
        # special case for IE
        css.gsub!(/:first-(line|letter)(\{|,)/, ':first-\1 \2')
        
        # no space after the end of a preserved comment
        css.gsub!(/\*\/ /, '*/')
        
        # If there is a @charset, then only allow one, and push to the top of the file.
        css.gsub!(/^(.*)(@charset "[^"]*";)/i, '\2\1')
        css.gsub!(/^(\s*@charset [^;]+;\s*)+/i, '\1')
        
        # Put the space back in some cases, to support stuff like
        # @media screen and (-webkit-min-device-pixel-ratio:0){
        css.gsub!(/\band\(/i, "and (")
        
        # remove unnecessary semicolons
        css.gsub!(/;+\}/, '}')
        
        # Replace 0(%, em, ex, px, in, cm, mm, pt, pc) with just 0.
        css.gsub!(/([\s:])([+-]?0)(?:%|em|ex|px|in|cm|mm|pt|pc)/i, '\1\2')
        
        # Replace 0 0 0 0; with 0.
        css.gsub!(/:(?:0 )+0(;|\})/, ':0\1')
        
        # Restore background-position:0 0; if required
        css.gsub!(/background-position:0(;|\})/i, 'background-position:0 0\1')
        
        # Replace 0.6 with .6, but only when preceded by : or a space.
        css.gsub!(/(:|\s)0+\.(\d+)/, '\1.\2')
        
        # Shorten colors from rgb(51,102,153) to #336699
        # This makes it more likely that it'll get further compressed in the next step.
        css.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |match|
          '#' << $1.scan(/\d+/).map{|n| n.to_i.to_s(16).rjust(2, '0') }.join
        end
        
        # Shorten colors from #AABBCC to #ABC. Note that we want to make sure
        # the color is not preceded by either ", " or =. Indeed, the property
        #     filter: chroma(color="#FFFFFF");
        # would become
        #     filter: chroma(color="#FFF");
        # which makes the filter break in IE.
        css.gsub!(/([^"'=\s])(\s?)\s*#([0-9a-f])\3([0-9a-f])\4([0-9a-f])\5/i, '\1\2#\3\4\5')
        
        # shorter opacity IE filter
        css.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=")
        
        # Remove empty rules.
        css.gsub!(/[^\};\{\/]+\{\}/, '')
        
        if (line_length > 0)
          # Some source control tools don't like it when files containing lines longer
          # than, say 8000 characters, are checked in. The linebreak option is used in
          # that case to split long lines after a specific column.
          startIndex = 0
          index = 0
          length = css.length
          while (index < length)
            index += 1
            if (css[index - 1,1] === '}' && index - startIndex > line_length)
              css = css.slice(0, index) + "\n" + css.slice(index, length)
              startIndex = index
            end
          end
        end
        
        # Replace multiple semi-colons in a row by a single one
        # See SF bug #1980989
        css.gsub!(/[;]+/, ';')
        
        #restore preserved comments and strings
        css = restore_preserved_comments_and_strings(css)
        
        # top and tail whitespace
        css.strip!
        
        @output_size = css.length
        css
      end
      
      private
      
      # Process comments (preserve special comments, nuke the rest) and strings
      # (preserve them).
      def process_comments_and_strings(css_text)
        css = css_text.clone
        
        startIndex = 0
        endIndex = 0
        i = 0
        max = 0
        token = ''
        totallen = css.length
        placeholder = ''
        
        # collect all comment blocks
        while (startIndex = css.index(/\/\*/, startIndex))
          endIndex = css.index(/\*\//, startIndex + 2)
          unless endIndex
            endIndex = totallen
          end
          token = css.slice(startIndex+2..endIndex-1)
          @comments.push(token)
          css = css.slice(0..startIndex+1).to_s + "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" + (@comments.length - 1).to_s + "___" + css.slice(endIndex, totallen).to_s
          startIndex += 2
        end
        
        # preserve strings so their content doesn't get accidentally minified
        css.gsub!(/("([^\\"]|\\.|\\)*")|('([^\\']|\\.|\\)*')/) do |match|
          quote = match[0,1]
          string = match.slice(1..-2)
          
          # maybe the string contains a comment-like substring?
          # one, maybe more? put'em back then
          if string =~ /___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_/
            @comments.each_index do |index|
              string.gsub!(/___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{index.to_s}___/, @comments[index])
            end
          end
          
          # minify alpha opacity in filter strings
          string.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=")
          @preservedTokens.push(string)
          
          quote + "___YUICSSMIN_PRESERVED_TOKEN_" + (@preservedTokens.length - 1).to_s + "___" + quote
        end
        
        # used to jump one index in loop
        ie5_hack = false
        # strings are safe, now wrestle the comments
        @comments.each_index do |index|
          if ie5_hack
            ie5_hack = false
            next
          end
          
          token = @comments[index]
          placeholder = "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" + index.to_s + "___"
          
          # ! in the first position of the comment means preserve
          # so push to the preserved tokens keeping the !
          if (token[0,1] === "!")
            @preservedTokens.push(token)
            css.gsub!( /#{placeholder}/i,  "___YUICSSMIN_PRESERVED_TOKEN_" + (@preservedTokens.length - 1).to_s + "___")
            next
          end
          
          # \ in the last position looks like hack for Mac/IE5
          # shorten that to /*\*/ and the next one to /**/
          if (token[-1,1] === "\\")
            @preservedTokens.push("\\")
            css.gsub!( /#{placeholder}/,  "___YUICSSMIN_PRESERVED_TOKEN_" + (@preservedTokens.length - 1).to_s + "___")
            # keep the next comment but remove its content
            @preservedTokens.push("")
            css.gsub!(/___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{index+1}___/,  "___YUICSSMIN_PRESERVED_TOKEN_" + (@preservedTokens.length - 1).to_s + "___")
            ie5_hack = true
            next
          end
          
          # keep empty comments after child selectors (IE7 hack)
          # e.g. html >/**/ body
          if ((token.length === 0) && (startIndex = css.index( /#{placeholder}/)))
            if (startIndex > 2)
              if (css[startIndex - 3,1] === '>')
                @preservedTokens.push("")
                css.gsub!(/#{placeholder}/,  "___YUICSSMIN_PRESERVED_TOKEN_" + (@preservedTokens.length - 1).to_s + "___")
              end
            end
          end
          
          # in all other cases kill the comment
          css.gsub!( /\/\*#{placeholder}\*\//, "")
        end
        
        css
      end
      
      # Restore @preservedTokens back in to the css.
      def restore_preserved_comments_and_strings(clean_css)
        css = clean_css.clone
        css_length = css.length
        @preservedTokens.each_index do |index|
          # slice these back into place rather than regex, because
          # complex nested strings cause the replacement to fail
          placeholder = "___YUICSSMIN_PRESERVED_TOKEN_#{index}___"
          startIndex = css.index(placeholder, 0)
          next unless startIndex # skip if nil
          endIndex = startIndex + placeholder.length
          
          css = css.slice(0..startIndex-1).to_s + @preservedTokens[index] + css.slice(endIndex, css_length).to_s
        end
        
        css
      end
    end
 end

end