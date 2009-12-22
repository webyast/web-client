require 'active_resource/http_mock'
module ActiveResource
  class HttpMock
    class << self
      def set_authentification
        YaST::ServiceResource::Session.site = "http://localhost"
        YaST::ServiceResource::Session.login = "test"
        YaST::ServiceResource::Session.auth_token = "1234"
      end

      def authentification_header
        {"Authorization"=>"Basic OjEyMzQ="}
      end
    end

    class Responder
      def resources(routes,opts={})
        response = "<resources type=\"array\">"
        routes.each do |interface,path|
          response << "<resource><interface>#{interface}</interface><href>#{path}</href>"
          response << (opts[:policy] ? "<policy>#{opts[:policy]}</policy>" : "<policy/>")
          response << ("<singular type=\"boolean\">" + (opts[:policy].nil? ? "true" : opts[:policy].to_s) + "</singular>")
          response << "</resource>\n"
        end
        response << "</resources>"
        get   "/resources.xml",   {}, response, 200
      end

      def permissions(prefix,perm,opts={})
        response = "<permissions type=\"array\">"
        perm.each do |perm,granted| 
          response << "<permission>"
          response << "<granted type=\"boolean\">#{granted.to_s}</granted>"
          response << "<id>#{prefix}.#{perm.to_s}</id>"
          response << "</permission>"
        end
        response << "</permissions>"
        get   "/permissions.xml?filter=#{prefix}&user_id=test", HttpMock.authentification_header, response, 200
      end
    end

  end
end
