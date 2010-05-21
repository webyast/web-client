#--
# Webyast Webservice framework
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

#
# Added for Ruby-GetText-Package
#
require 'fileutils'

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext_rails/tools'
  GetText.create_mofiles
  destdir = File.join(File.dirname(__FILE__),"../../..", "webclient", "public", "vendor", "text")
  if File.directory?(destdir)
    # I am a plugin. In order to get the translation available the concerning mo files have to be
    # available in webservice/public/vendor/text/locale. That is needed in the development environment ONLY.
    srcdir = File.join(Dir.pwd,"locale")
    FileUtils.cp_r(srcdir, destdir) if File.directory?(srcdir)
  end
end

desc "Update pot/po files to match new version."
task :updatepot do
  require 'gettext_rails/tools'
  destdir = File.join(File.dirname(__FILE__),"../../..", "pot")
  Dir.mkdir destdir unless File.directory?(destdir)

  if File.basename(Dir.pwd) == "webclient"
    GetText.update_pofiles("yast_webclient", Dir.glob("{app,lib}/**/*.{rb,erb,rhtml}"),
                           "yast_webclient 1.0.0")
    filename = "yast_webclient.pot"
  else
    GetText.update_pofiles("yast_webclient_#{File.basename(Dir.pwd)}", Dir.glob("{app,lib}/**/*.{rb,erb,rhtml}"),
                           "yast_webclient #{File.basename(Dir.pwd)} 1.0.0")
    filename = "yast_webclient_#{File.basename(Dir.pwd)}.pot"
  end
  # Moving pot file to global pot directory
  File.rename(File.join(Dir.pwd,"po", filename), File.join(destdir, filename))
end

desc "Fetch po files from lcn. Parameter: source directory of lcn e.g. ...lcn/trunk/"
task :fetch_po, [:lcn_dir] do |t, args|
  args.with_defaults(:lcn_dir => File.join(File.dirname(__FILE__),"../../../../..", "lcn", "trunk"))  
  puts "Scanning #{args.lcn_dir}"
  po_files = File.join(args.lcn_dir, "**", "*.po")
  Dir.glob(po_files).each {|po_file|
    filename_array = File.basename(po_file).split(".")
    if filename_array[0] == "yast_webclient_#{File.basename(Dir.pwd)}" ||
       filename_array[0] == "yast_webclient" && File.basename(Dir.pwd) == "webclient"
       destdir = File.join(Dir.pwd, "po", filename_array[1])
       Dir.mkdir destdir unless File.directory?(destdir)
       destfile = File.join(destdir,filename_array[0]+".po")
       puts "copy #{po_file} --> #{destfile}"
       FileUtils.cp(po_file, destfile)
    end
  }
end

