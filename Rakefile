require 'fileutils'

env = ENV.map { |key,val| ENV[key] ? %(#{key}="#{ENV[key]}") : nil }.reject {|x| x.nil?}.join(' ')

plugins = Dir.glob('plugins/*')#.reject{|x| ['users'].include?(File.basename(x))}
PROJECTS = ['webclient', *plugins]
desc 'Run all tests by default'
task :default => :test


%w(makemo updatepot test test:ui rdoc pgem package release install install_policies check_syntax package-local buildrpm buildrpm-local test:test:rcov).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    PROJECTS.each do |project|
      puts "run into project #{project}"
      Dir.chdir project do
        if File.exist? "Rakefile" #avoid endless loop if directory doesn't contain Rakefile
          system %(#{env} #{$0} #{task_name})
          raise "Error on execute task #{task_name} on #{project}" if $?.exitstatus != 0
        end
      end
    end
  end
end

desc 'Deploy locally for development - convert .po => .mo and run rake db:migrate'
task :deploy_devel_all => :makemo do |t|
  project   = "webclient"
  task_name = "db:migrate"
  system %(cd #{project} && #{env} #{$0} #{task_name})
  raise "Error '#{$?.exitstatus}' on execute task #{task_name} on #{project}" if $?.exitstatus != 0
end

desc "Fetch po files from lcn. Parameter: source directory of lcn e.g. ...lcn/trunk/"
task :fetch_po, [:lcn_dir] do |t, args|
  args.with_defaults(:lcn_dir => File.join(File.dirname(__FILE__),"../../", "lcn", "trunk"))  
  #remove translation statistik
  File.delete(File.join("pot", "translation_status.yaml")) if File.exist?("pot/translation_status.yaml")
  result = Hash.new()
  task_name = "fetch_po"

  PROJECTS.each do |project|
      Dir.chdir project do
        if File.exist? "Rakefile" #avoid endless loop if directory doesn't contain Rakefile
          system %(#{env} #{$0} #{task_name}[#{args.lcn_dir}] )
          raise "Error on execute task #{task_name} on #{project}" if $?.exitstatus != 0
        end
      end

    #collecting translation information
    Dir.glob("#{project}/**/*.po").each {|po_file|
      output = `LANG=C msgfmt -o /dev/null -c -v --statistics #{po_file} 2>&1`
      language = File.basename(File.dirname(po_file))
      output.split(",").each {|column|
        value = column.split(" ")
        if value.size > 2 
          if result.has_key? language 
            if result[language].has_key? value[1]
              result[language][value[1]] += value[0].to_i
            else
              result[language][value[1]] = value[0].to_i
            end
          else
            result[language] = Hash.new
            result[language][value[1]] = value[0].to_i
          end
         end
      }
    }
  end
  
  #saving result to pot/translation_status.yaml
  destdir = File.join(File.dirname(__FILE__), "pot")
  Dir.mkdir destdir unless File.directory?(destdir)
  f = File.open(File.join(destdir, "translation_status.yaml"), "w")
  f.write(result.to_yaml)
  f.close

  #remove translations which have not at least 80 percent translated text
  limit = Float(80)
  result.each {|key,value|
    translated = un_translated = Float(0)
    translated = value["translated"].to_f if value.has_key? "translated"
    un_translated += value["untranslated"].to_f if value.has_key? "untranslated"
    un_translated += value["fuzzy"].to_f if value.has_key? "fuzzy"
    limit_eval = translated/(un_translated+translated) 
    if limit_eval < limit/100
      puts "Language #{key} should be deleted cause it has only #{(limit_eval*100).to_i} percent translation reached."
      Dir.glob("**/#{key}/").each {|po_dir|
        unless po_dir.include? "lang_helper" #do not delete translations for language selections
#          puts "deleting #{po_dir}"
#          remove_dir(po_dir, true) #force=true
        end
      }
    end      
  }
end
 
desc "Run doc to generate whole documentation"
task :doc do
  #clean old documentation
  puts "cleaning old doc"
  system "rm -rf doc"
  
  Dir.mkdir 'doc'
  copy 'index.html.template', "doc/index.html"
  #handle rest service separate from plugins
  puts "create framework documentation"
  Dir.chdir('webclient') do
    system "rake doc:app"
  end
    system "cp -r webclient/doc/app doc/webclient"
  puts "create plugins documentation"
  plugins_names = []
  Dir.chdir('plugins') do
    plugins_names = Dir.glob '*'
  end
  plugins_names.each do |plugin|
    Dir.chdir("plugins/#{plugin}") do
      system "rake doc:app" if File.exist? "Rakefile"
    end
    system "cp -r plugins/#{plugin}/doc/app doc/#{plugin}"
  end
  puts "generate links for plugins"
  code = ""
  plugins_names.sort.each do |plugin|
    code = "#{code}<a href=\"./#{plugin}/index.html\"><b>#{plugin}</b></a><br>"
  end
  system "sed -i 's:%%PLUGINS%%:#{code}:' doc/index.html"
  puts "documentation successfully generated"
end

=begin
require 'metric_fu'
MetricFu::Configuration.run do |config|
        #define which metrics you want to use
        config.metrics  = [:churn, :saikuro, :flog, :reek, :roodi, :rcov] #missing flay and stats both not working
        config.graphs   = [:flog, :reek, :roodi, :rcov]
        config.flay     = { :dirs_to_flay => ['webclient', 'plugins']  } 
        config.flog     = { :dirs_to_flog => ['webclient', 'plugins']  }
        config.reek     = { :dirs_to_reek => ['webclient', 'plugins']  }
        config.roodi    = { :dirs_to_roodi => ['webclient', 'plugins'] }
        config.saikuro  = { :output_directory => 'scratch_directory/saikuro', 
                            :input_directory => ['webclient', 'plugins'],
                            :cyclo => "",
                            :filter_cyclo => "0",
                            :warn_cyclo => "5",
                            :error_cyclo => "7",
                            :formater => "text"} #this needs to be set to "text"
        config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
        config.rcov     = { :test_files => ['webclient/test/**/*_test.rb', 
                                            'plugins/**/test/**/*_test.rb'],
                            :rcov_opts => ["--sort coverage", 
                                           "--no-html", 
                                           "--text-coverage",
                                           "--no-color",
                                           "--profile",
                                           "--rails",
                                           "--exclude /gems/,/Library/,spec"]}
    end
=end

