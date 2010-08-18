#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require "tempfile"
JSCOMPRESSOR = File.join(RAILS_ROOT, '/script/javascript/jsmin.rb')

def minify(list, output)
   tmp = Tempfile.open('all')
   list.each {|file| open(file) {|f| tmp.write(f.read) } }
   tmp.rewind 
   sh "ruby #{JSCOMPRESSOR} < #{tmp.path} > #{output}"
end

namespace :js do
  javascripts = ['jqplot.categoryAxisRenderer.js', "jqplot.dateAxisRenderer.js", "jqplot.canvasTextRenderer.js", "jqplot.cursor.js"]
  
  Dir.chdir(File.join(RailsParent.parent, 'public', 'javascripts', 'plugin')) do    
    
    javascripts.map! {|f| File.join(Dir.pwd, f)}
    javascripts.unshift(File.join(RailsParent.parent, 'public', 'javascripts', 'jquery.jqplot.js'))
    file 'status-min.js' => javascripts do | f |
      
      output_file = File.join(RailsParent.parent, 'public', 'javascripts', 'min', '/') + f.name
      minify(f.prerequisites, output_file)
    end
  end

  desc "Status module: minimize javascript source files for production environment"
  task :"status" => ['status-min.js']  do
     puts "Done"
  end
end