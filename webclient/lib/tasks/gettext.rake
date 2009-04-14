#
# Added for Ruby-GetText-Package
#

desc "Create mo-files for L10n"
task :makemo do
  require 'gettext_rails/tools'
  GetText.create_mofiles
end

desc "Update pot/po files to match new version."
task :updatepo do
  require 'gettext_rails/tools'
  GetText.update_pofiles("yast_webclient", Dir.glob("{app,lib}/**/*.{rb,erb,rhtml}"),
                         "yast_webclient 1.0.0")
end

