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

desc "Fetch po files from lcn. Parameter: source directory of lcn e.g. ...lcn/trunk/webyast/"
task :fetch_po, [:lcn_dir] do |t, args|
  args.with_defaults(:lcn_dir => File.join(File.dirname(__FILE__),"../../../../..", "lcn", "trunk","webyast"))  
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
  result = Hash.new()
  destdir = File.join(File.dirname(__FILE__),"../../..", "pot")
  Dir.mkdir destdir unless File.directory?(destdir)
  result = YAML.load(File.open(File.join(destdir, "translation_status.yaml"))) if File.exists?(File.join(destdir, "translation_status.yaml"))

  Dir.glob("{po}/**/*.po").each {|po_file|
    output = `LANG=C msgfmt -o /dev/null -c -v --statistics #{po_file} 2>&1`
    language = File.basename(File.dirname(po_file))
    output.split(",").each {|column|
       value = column.split(" ")
       if value.size > 2 
         unless result[language].blank? 
           unless result[language][value[1]].blank?
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
  f = File.open(File.join(destdir, "translation_status.yaml"), "w")
  f.write(result.to_yaml)
  f.close
end

