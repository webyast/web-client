#
# Copyright (c) 2010 Novell Inc.
#
# Based on
# http://github.com/accuser/flonch/blob/master/lib/response_validator.rb
# Copyright (c) 2009 Matthew Gibbons <mhgibbons@me.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
require 'nokogiri'
require 'tidy'
require File.join(File.dirname(__FILE__), '../../../app/helpers/view_helpers/html_helper')

module YaST
  module Rack
    
    class ResponseValidator
      include ViewHelpers::HtmlHelper
      
      DEFAULT_TIDY_OPTS = {
        'char-encoding'     => 'utf8',
        'indent'            => true,
        'indent-spaces'     => 2,
        'tidy-mark'         => false,
        'wrap'              => 0
      }
  
      #TIDY_LIB_PATH = '/opt/local/lib/libtidy.dylib'

      attr_accessor :options
  
      def initialize(app, options = {})
        options.stringify_keys!
        options.reverse_merge! DEFAULT_TIDY_OPTS
    
        #Tidy.path = TIDY_LIB_PATH
    
        self.options = options
    
        @app = app  
      end
  
      def call(env)
        dup.call!(env)
      end
  
      def call!(env)
        status, headers, response = @app.call(env)
    
        if should_validate? headers          
          response = ::Rack::Response.new(validate(response.body, :partial => xhr?(headers)), status, headers)
          response.finish
        else
          [ status, headers, response ]
        end
      end
  
      private

      # whether it is an ajax request
      def xhr?(headers)
        headers && headers['X-Requested-With'] && headers['X-Requested-With'].include?("XMLHttpRequest")
      end
      
      def should_validate?(headers)
        headers && ( (headers["Content-Type"] && headers["Content-Type"].include?("text/html")) or () ) 
      end
    
      def validate(content, opts={}) #:nodoc:

        first_line = content.each_line.to_a.first || ""
        if content.each_line.to_a.first.include?("DOCTYPE")
          content = "#{first_line}\n<html><head></head><body>#{content}</body></html>" if opts[:partial]
        end
        
        returning(doc = Nokogiri::HTML(content)) do
          Tidy.open(self.options) do |tidy|
            tidy.clean(content)
          
            unless tidy.errors.empty?
              (doc/'body').first.children.first.before("<div class='ui-state-error'><p><b>HTML errors:</b>:</p><pre>#{html_escape(tidy.errors)}</pre></div>")
            end
        end
        end.to_xhtml
      end
      
      HTML_ESCAPE	=	{ 
        '&' => '&amp;', 
        '>' => '&gt;', 
        '<' => '&lt;', 
        '"' => '&quot;' 
      }
    
      def html_escape(s)
        s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
      end
    end

  end
end