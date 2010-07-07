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

#inject to ActiveResource xml serializer fix to_xml method
require "yast_model/xml_fix.rb"

include LangHelper

# ==YastModel module
# Extension to set correctly ActiveResource model for webyast purpose
# (multiple hosts and multiple users)
module YastModel
  # == Base module
  # Main extension for ActiveResource Models which provide 
  # required functionlity
  # 
  # === Example usage
  #   class C < ActiveResource::Base
  #     extend YastModel::Base
  #     model_interface :'org.opensuse.yast.modules.yapi.time'
  #   end
  module Base

    # tests if connection is valid for current user 
    # ( correct site and authentificate token)
    def valid_connection?(site = self.site, password = self.password)
     return !(
         site.blank? ||
         site != URI.parse(YaST::ServiceResource::Session.site) ||
         password != YaST::ServiceResource::Session.auth_token
         )
    end

    #extend connection getter with automatic invalidation if connection is not valid
    # see valid_connection?
    def connection(*args)
      #check if connection is still valid
      unless valid_connection?
        set_site
      end
      super args
    end

    # Overwritten default initial prefix methods
    #
    # Note:: this is not endless recursion because set_site sets prefix, which overwrittes method prefix
    # 
    # +FIXME+ :: If changing site could change also prefix, this doesn't work.
    # Then is needed rewrite also prefix= and prefix_source and use lazy loading of variable instead of dynamic changing methods (bad rails idea to do it).
    def prefix(*args)
      set_site
      prefix args
    end

    # Specifies interface for model (webyast rest-service
    # defines interface which implement and path to implementation on site)
    def model_interface(i)
      @interface = i.to_sym
    end

    # enrich site getter from ActiveResource with validation of site (needed because site could change)
    def site
      ret = super

      if valid_connection? ret
        return ret
      else
        set_site
        return super #call again super to properly call all hooks after set new site
      end
    end

    def permission_prefix
      @policy.blank? ?  @interface : @policy
    end

    # Sets new site to model, together with path of interface on target machine and password for user
    # also invalidates old permissions
    def set_site
      self.site = YaST::ServiceResource::Session.site
      self.password = YaST::ServiceResource::Session.auth_token
 
      #Setting language in the header of the http request
      self.headers["ACCEPT_LANGUAGE"] = current_locale 

#      YastModel::Resource.site = self.site  #dynamic set site
      #FIXME not thread safe, (whole using resource with site set class variable is not thread save
      Rails.logger.debug "read interface to #{@interface.to_s}"
      Rails.logger.debug "set site tot #{self.site}"
      Rails.logger.debug "set token to #{self.password}"
#      resource = YastModel::Resource.find(:all).find { |r| r.interface.to_sym == @interface.to_sym }
      resource = ResourceCache.instance.resources[@interface.to_sym]
      #TODO throw better exception if not found
      raise "Interface #{@interface} missing on target machine" unless resource
      p, sep, self.collection_name = resource.href.rpartition('/')
      p += '/'
      self.prefix = p
      self.element_name = collection_name
      @policy = resource.policy
    end

    # Overwritten implementation from ActiveResource as it requires site, which
    # is incoherent with rest of find methods (whole ARes single resource
    # implementation has some gaps)
    def find_one(options)
      case from = options[:from]
      when Symbol
        instantiate_record(get(from, options[:params]))
      when String
        path = "#{from}#{query_string(options[:params])}"
        instantiate_record(connection.get(path, headers))
      else
        prefix_options, query_options = split_options(options[:params])
        path = self.collection_path(prefix_options, query_options)
        instantiate_record( (connection.get(path, headers)), prefix_options )
      end
    end

    # gets permissions for target service
    # Note: it lazy loads permissions so first call for site take more time
    # Note: it is class method, because user, password and site is also on class level
    def permissions
      set_site #set site which sets also policy if model has a policy
#      YastModel::Permission.site = YaST::ServiceResource::Session.site
#      YastModel::Permission.password = YaST::ServiceResource::Session.auth_token
#      permissions = YastModel::Permission.find :all, :params => { :user_id => YaST::ServiceResource::Session.login, :filter => permission_prefix }
      permissions = ResourceCache.instance.permissions.select { |perm| perm.id.to_s.index(permission_prefix.to_s) == 0 }
      Rails.logger.debug permissions.inspect
      @permissions = {}
      permissions.each do |p|
        key = p.id
        key.slice! "#{permission_prefix}."
        Rails.logger.debug "sliced: #{key} granted?: #{p.granted.inspect}"
        @permissions[key.to_sym] = p.granted
      end
      @permissions
    end
  end
end
