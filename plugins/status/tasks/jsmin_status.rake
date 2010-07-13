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