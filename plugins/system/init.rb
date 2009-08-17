# Include hook code here

# always reload all files in development mode
if ENV['RAILS_ENV'] == 'development'
    # get all subdirectories in app/
    dirs = Dir[File.join(directory, 'app', '*')].reject{|x| not File.directory?(x)}

    dirs.each do |dir|
	$LOAD_PATH << dir
	ActiveSupport::Dependencies.load_paths << dir
	ActiveSupport::Dependencies.load_once_paths.delete(dir)
    end
end

# vim: ft=ruby
