# public/javascripts/jquery-1.4.2.js
# public/javascripts/jquery.js',

#############################################################
# use command line parameter like: rake js:min module=status
# TODO: move js.rake and /script/javascript/jsmin.rb to webyast-tasks
#############################################################

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
      libs = ['public/javascripts/jquery-1.4.2.js',
	      'public/javascripts/jquery.query.js',
	      'public/javascripts/jquery.timers.js',
	      'public/javascripts/jquery.ui.custom.js',
	      'public/javascripts/jquery.validate.js',
	      'public/javascripts/validation.js',
	      'public/javascripts/jqbrowser-compressed.js',
	      'public/javascripts/jquery.badbrowser.js',
	      'public/javascripts/jquery.jqModal.js',
	      'public/javascripts/jquery.ui.core.js',
	      'public/javascripts/jquery.ui.tabs.js',
	      'public/javascripts/yast.widgets.js',
	      'public/javascripts/yast.helpers.js',
	      'public/javascripts/browser_fixes.js',
	      'public/javascripts/jrails.js',
	      'public/javascripts/jquery.quicksearch.js',
	      'public/javascripts/digitalspaghetti.password.js',
	      'public/javascripts/script.js']

      #'public/javascripts/script.js', ???
      #'public/javascripts/application.js', ???

      # paths to jsmin script and final minified file
      final = 'public/javascripts/min/webclient-base-min.js'

    elsif args[:module] == 'users'

      # list of files to minify
      libs = ['../plugins/users/public/javascripts/users.js',
	      'public/javascripts/select_dialog.js',
	      'public/javascripts/excanvas.js']

      

      #final = '../plugins/users/public/javascripts/users-group-min.js'
      final = 'public/javascripts/min/users-group-min.js'

    elsif args[:module] == 'status'

      # list of files to minify
      libs = ['public/javascripts/jquery.jqplot.js',
	      'public/javascripts/plugin/jqplot.categoryAxisRenderer.js',
	      'public/javascripts/plugin/jqplot.dateAxisRenderer.js',
	      'public/javascripts/plugin/jqplot.canvasTextRenderer.js',
	      'public/javascripts/plugin/jqplot.cursor.js']

      final = 'public/javascripts/min/jqplot-status-min.js'
 
    else

      raise "error: unknown error"

    end
  
      # create single tmp js file
      tmp = Tempfile.open('all')
      libs.each {|lib| open(lib) {|f| tmp.write(f.read) } }
      tmp.rewind

      # minify file
      %x[ruby #{jsmin} < #{tmp.path} > #{final}]
      puts "\n#{final}"
     
  end
end

