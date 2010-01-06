require 'active_resource/http_mock'
module ActiveResource
  class HttpMock
    class << self
      # sets authentification for webyast structure to generate proper
      # authentification header
      def set_authentification
        YaST::ServiceResource::Session.site = "http://localhost"
        YaST::ServiceResource::Session.login = "test"
        YaST::ServiceResource::Session.auth_token = "1234"
      end

      # Gets authentification header which must send request for authentification
      # to rest-service
      def authentification_header
        {"Authorization"=>"Basic OjEyMzQ="}
      end
    end

    class Responder
      # generate request to introspect target rest-service
      # routes:: hash with format interface => path
      # opts:: hash with additional options (keys policy with value and singular with true if resource is singular)
      def resources(routes,opts={})
        response = "<resources type=\"array\">"
        routes.each do |interface,path|
          response << "<resource><interface>#{interface}</interface><href>#{path}</href>"
          response << (opts[:policy] ? "<policy>#{opts[:policy]}</policy>" : "<policy/>")
          response << ("<singular type=\"boolean\">" + (opts[:singular].nil? ? "true" : opts[:singular].to_s) + "</singular>")
          response << "</resource>\n"
        end
        response << "</resources>"
        get   "/resources.xml",   {}, response, 200
      end

      # generate response for permission request
      # prefix:: prefix of permissions (filter passed to permission call)
      # perm:: hash with permissin as key and boolean if permission is granted
      # opts:: additional options (not used yet)
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
