begin
        require 'tasks/webservice'
rescue LoadError => e
        $stderr.puts "Install rubygem-yast2-webservice-tasks.rpm"
end

desc "Create mo-files for L10n"
task :makemo do
    require 'gettext_rails/tools'
      GetText.create_mofiles
end

desc "Update pot/po files to match new version."
task :updatepo do
    require 'gettext_rails/tools'
    GetText.update_pofiles("yast_webclient_language", Dir.glob("{app,lib}/**/*.{rb,erb,rhtml}"),
                                                     "yast_webclient language 1.0.0")
end
