require "tempfile"
vars = ['JSMIN', 'JAVASCRIPTS_PATH']

JSMIN = File.join(RAILS_ROOT, '/script/javascript/jsmin.rb')
JAVASCRIPTS_PATH = "#{RAILS_ROOT}/public/javascripts" 

def minify(list, output)
   tmp = Tempfile.open('all')
    list.each {|file| open(file) {|f| tmp.write(f.read) } }
    tmp.rewind 

    sh "ruby #{JSMIN} < #{tmp.path} > #{output}"
end

namespace :js do
  javascripts = ["jquery-1.4.2.js", "jquery.query.js", "jquery.timers.js", "jquery.ui.custom.js", "jquery.validate.js", "validation.js",
	           "jqbrowser-compressed.js", "jquery.badbrowser.js", "jquery.jqModal.js", "jquery.ui.core.js", "jquery.ui.tabs.js", 
	           "yast.widgets.js", "yast.helpers.js", "browser_fixes.js", "jrails.js", "jquery.quicksearch.js", "digitalspaghetti.password.js", "script.js"]  

  Dir.chdir(JAVASCRIPTS_PATH) do
    javascripts.map! {|f| File.join(Dir.pwd, f)}
    file 'base-min.js' => javascripts do | f |
      output_file = File.join(File.dirname(f.name), 'public/javascripts/min/') + f.name
      minify(f.prerequisites, output_file)
    end
  end

  desc 'Minimize Javascripts'
  task :"base" => ['base-min.js']  do
    puts "\nDone"
  end
end
