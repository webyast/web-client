# load common (rest-service, web-client) rake task
begin
  # assume development environment
  commondir = File.expand_path(File.join('..','..','..', '..', 'rest-service', 'webservice-tasks', 'lib'), File.dirname(__FILE__))
  $:.unshift(commondir) if File.directory?( commondir )
  require 'tasks/webservice'
rescue LoadError => e
  $stderr.puts "Install rubygem-yast2-webservice-tasks.rpm"
end
