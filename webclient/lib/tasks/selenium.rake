
# try loading all selenium task definitions
begin
    require 'selenium/rake/tasks'
rescue LoadError => e
    $stderr.puts "WARNING: 'selenium-client' gem is missing, UI testing task (test:ui) will be missing."
    $stderr.puts "Install 'selenium-client' Ruby gem from 'rubygem-selenium-client' RPM package.\n"
    return
end

# define selenium:rc:start task
Selenium::Rake::RemoteControlStartTask.new do |rc|
    rc.port = 4444
    rc.timeout_in_seconds = 3 * 60
    rc.background = true
    rc.wait_until_up_and_running = true
    rc.jar_file = Dir["vendor/selenium-remote-control/selenium-server*.jar"].first
    rc.additional_args << "-singleWindow"
end

# define selenium:rc:stop task
Selenium::Rake::RemoteControlStopTask.new do |rc|
    rc.host = "localhost"
    rc.port = 4444
    rc.timeout_in_seconds = 3 * 60
end

namespace :test do
    # define test:ui:check task
    Rake::TestTask.new(:"ui:check") do |t|
	t.libs << "test"
	t.pattern = 'test/ui/**/*_test.rb'
	t.verbose = true
    end

    Rake::Task['test:ui:check'].comment = "Note: Selenium Server must be running"

    # define test:ui task - start/shut down Selenium server component automatically
    desc 'Run UI tests using Selenium testing framework'
    task :ui => [:"selenium:rc:start", :"test:ui:check", :"selenium:rc:stop"]
end

# vim: ft=ruby
