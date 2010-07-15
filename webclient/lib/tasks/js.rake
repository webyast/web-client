#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

#############################################################
# Use command line parameter like: rake js:min module=base
# 
#############################################################

INPUT_DIRECTORY_JAVSCRIPTS = "#{RAILS_ROOT}/public/javascripts"
INPUT_DIRECTORY_JAVSCRIPTS_PLUGIN = "#{RAILS_ROOT}/public/javascripts/plugin"
OUTPUT_DIRECTORY_JAVSCRIPTS_MIN = "#{RAILS_ROOT}/public/javascripts/min"

namespace :js do
  desc "Minify javascript src for production environment"
  task :min, :module, :needs=>:environment do |t, args|

    # paths to jsmin script and final minified file
    jsmin = 'script/javascript/jsmin.rb'
    
    
    unless ENV.include?('module') && (ENV['module']=='base' || ENV['module']=='users' || ENV['module']=='status')
      raise "usage: rake output= # valid formats are [base] or [users] or [status]" 
    end

    if args[:module] == 'base'
      
      # list of files to minify
      libs = Array.new
      scripts = ["jquery-1.4.2", "jquery.query", "jquery.timers", "jquery.ui.custom", "jquery.validate", "validation",
		 "jqbrowser-compressed", "jquery.badbrowser", "jquery.jqModal", "jquery.ui.core", "jquery.ui.tabs", 
		 "yast.widgets", "yast.helpers", "browser_fixes", "jrails", "jquery.quicksearch", "digitalspaghetti.password", "script"]

      
      final = OUTPUT_DIRECTORY_JAVSCRIPTS_MIN + '/webclient-base-min.js'

      scripts.each do |name|
	libs.push (INPUT_DIRECTORY_JAVSCRIPTS + '/' + name + '.js')
      end


    elsif args[:module] == 'users'

      # list of files to minify
      libs = Array.new
      scripts = ['select_dialog', 'excanvas']

      

      # users.js stored in plugin directory?
      libs.push ('../plugins/users/public/javascripts/users.js')

      scripts.each do |name|
	libs.push (INPUT_DIRECTORY_JAVSCRIPTS + '/' + name + '.js')
      end

      final = OUTPUT_DIRECTORY_JAVSCRIPTS_MIN + '/users-group-min.js'

    elsif args[:module] == 'status'

      # list of files to minify
      libs = Array.new
      scripts = ['jqplot.categoryAxisRenderer', "jqplot.dateAxisRenderer", "jqplot.canvasTextRenderer", "jqplot.cursor"]

      # jquery.jqplot.js stored in javascripts directory
      libs.push (INPUT_DIRECTORY_JAVSCRIPTS + '/jquery.jqplot.js')

      scripts.each do |name|
	libs.push (INPUT_DIRECTORY_JAVSCRIPTS_PLUGIN + '/' + name + '.js')
      end
  
      final = OUTPUT_DIRECTORY_JAVSCRIPTS_MIN + '/jqplot-status-min.js'

    else
      raise "error: unknown error"
    end
 

    # create single tmp js file
    puts "Input:"
    puts libs

    tmp = Tempfile.open('all')
    libs.each {|lib| open(lib) {|f| tmp.write(f.read) } }
    tmp.rewind       
    

    # minify file
    %x[ruby #{jsmin} < #{tmp.path} > #{final}]

    puts "\nOutput:"
    puts "#{final}"

  end
end
