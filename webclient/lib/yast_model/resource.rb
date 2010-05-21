#--
# Webyast Webservice framework
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

module YastModel
  # Resource model
  # Model for resources which provide each webyast rest-service to allow
  # introspect. for details see restdoc of webyast rest-service
  class Resource < ActiveResource::Base
    #Resources on target machine has always constant prefix to allow introspect
    self.prefix = '/'

    # helper to check if interfaces is available on target machine
    #
    # === params
    # args:: interfaces to check
    # returns:: true if all passed interface is available on logged machine
    # 
    # === usage
    #   res = YastModel::Resource.interfaces_available? :'org.opensuse.int1', :'org.opensuse.int2'
    def self.interfaces_available?(*args)
      self.site = YaST::ServiceResource::Session.site
      res = Resource.find :all
      args.each do |int|
        found = res.find{ |v| v.interface.to_sym == int.to_sym }
        return false if found.nil?
      end
      return true
    end
  end
end
