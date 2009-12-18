module YastModel
  class Base < ActiveResource::Base

  def self.model_interface(i)
    @@interface = i.to_sym
  end

  def self.site
    ret = super
    if ret.nil? || ret != URI.parse(YaST::ServiceResource::Session.site) ||
        password != YaST::ServiceResource::Session.auth_token
      set_site
    end
    return ret
  end

  def self.set_site
    self.site = YaST::ServiceResource::Session.site
    self.password = YaST::ServiceResource::Session.auth_token
    Resource.site = "#{self.site}/" #resource has constant prefix to allow introspect
#FIXME not thread save
    Rails.logger.debug "read interface to #{@interface.to_s}"
    resource = Resource.find(:all).find { |r| r.interface.to_sym == @@interface.to_sym }
#TODO throw exception if not find
    prefix, sep, collection_name = resource.href.rpartition('/')
    prefix += '/'
    prefix = Pathname.new prefix
  end

#fix ARs broken singleton
  def self.find_one(options)
    case from = options[:from]
    when Symbol
      instantiate_record(get(from, options[:params]))
    when String
      path = "#{from}#{query_string(options[:params])}"
      instantiate_record(connection.get(path, headers))
    else
      prefix_options, query_options = split_options(options[:params])
      path = collection_path(prefix_options, query_options)
      instantiate_record( (connection.get(path, headers)), prefix_options )
    end
  end

  end
end
