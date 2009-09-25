#
# Added for Ruby-GetText-Package
#

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext_rails/tools'
  GetText.create_mofiles
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

