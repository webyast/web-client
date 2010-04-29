#!/usr/bin/env ruby
#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++
#
# check-setup.rb
#
# Tests correct setup of webclient
#

###
# Helpers
#

def escape why, fix = nil
  $stderr.puts "*** Error: #{why}"
  $stderr.puts "Please #{fix}" if fix
  exit
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

def test_version package, version
  v = `rpm -q #{package}`
  escape v, "install #{package} >= #{version}" if v =~ /is not installed/
  nvr = v.split "-"
  rel = nvr.pop
  ver = nvr.pop
  escape "#{package} not up-to-date", "upgrade to #{package}-#{version}"  if ver < version
end

###
# Tests
#

test_module 'rubygems', 'rubygems'

test_module 'gettext', 'rubygem-gettext_rails'

puts "All fine, webclient is ready to run"
