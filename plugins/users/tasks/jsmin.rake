#require "logger"
#log = Logger.new(STDOUT)
#log.level = Logger::DEBUG

namespace :js do
  javascripts = ['select_dialog.js', 'excanvas.js']
  
  Dir.chdir(File.join(RAILS_ROOT, 'public', 'javascripts')) do    
    javascripts.map! {|f| File.join(Dir.pwd, f)}
      #users.js stored in the plugin folder!!!
      javascripts.push(File.join(File.dirname(__FILE__), '/../public/javascripts/users.js'))

    file 'users-min.js' => javascripts do | f |
      output_file = File.join(File.dirname(__FILE__), '/../public/javascripts/') + f.name
      minify(f.prerequisites, output_file)
    end
  end

  desc "Minimize javascript source files for production environment"
  task :"users" => ['users-min.js']  do
     puts "Done"
  end
end
