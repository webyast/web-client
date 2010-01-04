module YastModel
  module Base

      def connection
        #check if connection is still valid
        if self.site.nil? || self.site != URI.parse(YaST::ServiceResource::Session.site) || self.password != YaST::ServiceResource::Session.auth_token
          set_site
        end
        super
      end

      def model_interface(i)
        @interface = i.to_sym
      end

      def interface
        @interface
      end

      def site
        ret = super
        Rails.logger.debug "read interface to #{@interface.to_s}"
        Rails.logger.debug "site is #{ret.to_s} and should be #{YaST::ServiceResource::Session.site}"
        Rails.logger.debug "pwd is #{password} and should be #{YaST::ServiceResource::Session.auth_token}"

        if ret.nil? || ret != URI.parse(YaST::ServiceResource::Session.site) || password != YaST::ServiceResource::Session.auth_token
          Rails.logger.debug "set new site for interface #{@interface}"
          set_site
        end
        return super
      end

      def set_site
        @permissions = nil #reset permission as it can be for each site and for each user different
        self.site = YaST::ServiceResource::Session.site
        self.password = YaST::ServiceResource::Session.auth_token
        YastModel::Resource.site = "#{self.site}/" #resource has constant prefix to allow introspect
        #FIXME not thread save
        Rails.logger.debug "read interface to #{@interface.to_s}"
        Rails.logger.debug "set site tot #{self.site}"
        Rails.logger.debug "set token to #{self.password}"
        resource = YastModel::Resource.find(:all).find { |r| r.interface.to_sym == @interface.to_sym }
        #TODO throw exception if not find
        p, sep, self.collection_name = resource.href.rpartition('/')
        p += '/'
        self.prefix = p
        self.element_name = collection_name
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

    def permissions
      return @permissions if @permissions
      YastModel::Permission.site = self.site #resource has constant prefix to allow introspect
      YastModel::Permission.password = self.password #resource has constant prefix to allow introspect
      permissions = YastModel::Permission.find :all, :params => { :user_id => YaST::ServiceResource::Session.login, :filter => @interface }
      @permissions = {}
      permissions.each do |p|
        key = p.id
        key.slice! "#{@interface}."
        @permissions[key.to_sym] = p.granted
      end
      @permissions
    end
  end
end
