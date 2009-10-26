$selenium_available = false

begin
    # try loading all selenium task definitions
    require 'selenium/rake/tasks'
    $selenium_available = true
    # define selenium:rc:start task

    # this is GIT file location (used when running directly from GIT)
    jar_file = Dir.glob(File.join(File.dirname(__FILE__),"../../..", "selenium/selenium-server*.jar")).first

    # this is RPM package location
    if jar_file.nil?
	jar_file = Dir.glob(File.join(File.dirname(__FILE__),"../..", "vendor/selenium-remote-control/selenium-server*.jar")).first
    end

    if jar_file.nil?
	namespace :'selenium:rc' do
	    desc "Start Selenium server"
	    task :start do
		raise "Error: selenium-server-*.jar file was not found"
	    end

	    desc "Stop Selenium server"
	    task :stop do
		raise "Error: selenium-server-*.jar file was not found"
	    end
	end
    else
	Selenium::Rake::RemoteControlStartTask.new do |rc|
	      rc.port = 4444
	      rc.timeout_in_seconds = 3 * 60
	      rc.background = true
	      rc.wait_until_up_and_running = true
	      rc.jar_file = jar_file
	      rc.additional_args << "-singleWindow"
	end

	# define selenium:rc:stop task
	Selenium::Rake::RemoteControlStopTask.new do |rc|
	      rc.host = "localhost"
	      rc.port = 4444
	      rc.timeout_in_seconds = 3 * 60
	end
    end
rescue LoadError
end

namespace :sinatra do
    task :start do
      cmd = "ruby #{File.join(File.dirname(__FILE__),"../..", "test/dummy-host/host.rb")} &"
      system cmd
    end
    task :stop do
      system "ps a|grep dummy-host/host.rb|cut -c -6 | xargs kill -SIGTERM"
    end
end

namespace :webric do
    task :start do
      cmd = "#{File.join(File.dirname(__FILE__),"../..", "script/server")} -p 4568 &"
      system cmd
    end
    task :stop do
      system "ps a|grep server|grep 4568|cut -c -6 | xargs kill -SIGTERM"
    end
end

namespace :test do
    # define test:ui:check task
    Rake::TestTask.new(:"ui:check") do |t|
	      t.libs << "test"
	      t.pattern = 'test/ui/**/*_test.rb'
	      t.verbose = true
    end

    Rake::Task['test:ui:check'].comment = "Note: Selenium Server must be running"

    begin
      require 'test/unit/version'
      # require test-unit version 2.x
      test_unit_present = (Test::Unit::VERSION =~ (/^2\./)).zero?
    rescue LoadError
      test_unit_present = false
    end

    # define test:ui task - start/shut down Selenium server component automatically
    desc 'Run UI tests using Selenium testing framework'
    if not $selenium_available
      task :ui do 
	    $stderr.puts "ERROR: 'selenium-client' gem is missing, UI testing task (test:ui)"
	    $stderr.puts "       cannot be started. Install 'selenium-client' Ruby gem first."
	    exit 1
      end
    elsif !test_unit_present
      task :ui do
	    $stderr.puts "ERROR: 'test-unit' gem is missing, UI testing task (test:ui)"
	    $stderr.puts "       cannot be started. Install 'test-unit' Ruby gem first."
	    exit 1
      end
    else
	  task :ui => [:"webric:start",:"sinatra:start", :"selenium:rc:start", :"test:ui:check", :"selenium:rc:stop", :"sinatra:stop", :"webric:stop"]
    end
end

# vim: ft=ruby
