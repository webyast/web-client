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
  # == Permission model
  # Model for permission setup on target system.
  #
  # for details see restdoc of permission service
  class Permission < ActiveResource::Base
    YAPI_STR = "org.opensuse.yast.modules.yapi."
    YAPI_LEN = YAPI_STR.size
    YSR_STR = "org.opensuse.yast.modules.ysr"
    YSR_NEW_STR = "registration"
    MAX_PERM_LEN = 512


    def pretty_id
      cutted = id
      cutted = cutted[YAPI_LEN,512] if cutted.start_with? YAPI_STR
      return cutted.gsub YSR_STR,YSR_NEW_STR
    end
  
    def self.deprettify_id (pretty_id,perms=[])
      pretty_id = pretty_id.gsub YSR_NEW_STR, YSR_STR
      perms = Permission.find(:all) if perms.empty?
      perms.collect { |p| p.id }.find { |id| id.include? pretty_id }
    end

  end

end
