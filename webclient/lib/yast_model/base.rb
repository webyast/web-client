module YastModel
  class Base < ActiveResource::Base
    self.logger = Rails.logger #avoid problem with nil logger

    class << self
      def model_interface(i)
        @@interface = i.to_sym
      end

      alias_method :site_orig, :site
      def site
        ret = site_orig
        if ret.nil? || ret != URI.parse(YaST::ServiceResource::Session.site) ||
            password != YaST::ServiceResource::Session.auth_token
          set_site
        end
        return site_orig
      end

      def set_site
        site = YaST::ServiceResource::Session.site
        self.site = site
        self.password = YaST::ServiceResource::Session.auth_token
        YastModel::Resource.site = "#{site}/" #resource has constant prefix to allow introspect
        #FIXME not thread save
        Rails.logger.debug "read interface to #{@@interface.to_s}"
        resource = YastModel::Resource.find(:all).find { |r| r.interface.to_sym == @@interface.to_sym }
        #TODO throw exception if not find
        p, sep, @@collection_name = resource.href.rpartition('/')
        p += '/'
        self.prefix = p
      end

#redefine collection name as it is little broken see http://lists.opensuse.org/opensuse-ruby/2009-12/msg00008.html
      def collection_name
        @@collection_name
      end

      #fix ARs broken singleton
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
    end
  end
end
