###
# Helpers
#

class Error
  @@errors = 0
  def self.inc
    @@errors += 1
  end
  def self.errors
    @@errors
  end
end

def escape why, fix = nil
  $stderr.puts "*** ERROR: #{why}"
  $stderr.puts "Please #{fix}" if fix
  exit(1) unless ENV["SYSTEM_CHECK_NON_STRICT"]
  Error.inc
end

def warn why, fix = nil
  $stderr.puts "*** WARNING: #{why}"
  $stderr.puts "Please #{fix}" if fix
end

def test what
  escape "(internal error) wrong use of 'test'" unless block_given?
  puts "Testing if #{what}"
  yield
end

def test_module name, package
  puts "Testing if #{package} is installed"
  begin
    require name
  rescue Exception => e
    escape "#{package} not installed", "install #{package}"
  end
end

def test_version package, version = nil
  old_lang = ENV['LANG']
  ENV['LANG'] = 'C'
  v = `rpm -q #{package}`
  ENV['LANG'] = old_lang
  if v =~ /is not installed/
    escape v, "install #{package} >= #{version}" if version
    escape v, "install #{package}"
  end
  return unless version # just check package, not version
  nvr = v.split "-"
  rel = nvr.pop
  ver = nvr.pop
  escape "#{package} not up-to-date", "upgrade to #{package}-#{version}"  if ver < version
end

###
# Tests
#

desc "Check that your build environment is set up correctly for WebYaST"
task :system_check do

  # check if openSUSE 11.2 or SLE11

  os_version = "unknown"
  begin
    suse_release = File.read "/etc/SuSE-release"
    suse_release.scan( /VERSION = ([\d\.]*)/ ) do |v|
      os_version = v[0]
    end if suse_release
  rescue
  end
  
  #
  # check needed needed packages
  #
  version = "0.0.1" # do not take care
  test_version "libsqlite3-0", version
  test_version "rubygem-gettext_rails"
  
  #
  # check needed modules
  # 
  test_module "rake", "rubygem-rake"
  test_module "sqlite3", "rubygem-sqlite3"
  test_module "rake", "rubygem-rake"

  
  if Error.errors == 0
    puts ""
    puts "****************************************"
    puts "All fine, WebYaST client is ready to run"
    puts "****************************************"
  else
    puts ""
    puts "******************************************************"
    puts "Please, fix the above errors before running the client"
    puts "******************************************************"
  end
end
