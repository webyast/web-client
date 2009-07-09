env = %(PKG_BUILD="#{ENV['PKG_BUILD']}") if ENV['PKG_BUILD']
 
PROJECTS = ['webclient', *Dir.glob('plugins/*')]

desc 'Run all tests by default'
task :default => :test
 
%w(test rdoc pgem package release).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    PROJECTS.each do |project|
      system %(cd #{project} && #{env} #{$0} #{task_name})
    end
  end
end

desc "Check syntax of all Ruby files."
task :check_syntax do
    `find . -name "*.rb" |xargs -n1 ruby -c |grep -v "Syntax OK"`
      puts "* Done"
end

