env = ENV.map { |key,val| ENV[key] ? %(#{key}="#{ENV[key]}") : nil }.reject {|x| x.nil?}.join(' ')

plugins = Dir.glob('plugins/*')#.reject{|x| ['users'].include?(File.basename(x))}
PROJECTS = ['webclient', *plugins]
desc 'Run all tests by default'
task :default => :test


%w(makemo updatepo test test:ui rdoc pgem package release install install_policies check_syntax package-local buildrpm buildrpm-local test:test:rcov).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    PROJECTS.each do |project|
      system %(cd #{project} && #{env} #{$0} #{task_name})
      raise "Error on execute task #{task_name} on #{project}" if $?.exitstatus != 0
    end
  end
end
 

