module ActionController
  class UrlRewriter
      #monkey patch for url rewriter to allow easy change of port in url_for
      def rewrite_url(options)
      rewritten_url = ""

      unless options[:only_path]
        rewritten_url << (options[:protocol] || @request.protocol)
        rewritten_url << "://" unless rewritten_url.match("://")
        rewritten_url << rewrite_authentication(options)
        rewritten_url << (options[:host] || options.key?(:port) ? @request.host : @request.host_with_port )
        rewritten_url << ":#{options.delete(:port)}" if options.key?(:port)
      end

      path = rewrite_path(options)
      rewritten_url << ActionController::Base.relative_url_root.to_s unless options[:skip_relative_url_root]
      rewritten_url << (options[:trailing_slash] ? path.sub(/\?|\z/) { "/" + $& } : path)
      rewritten_url << "##{CGI.escape(options[:anchor].to_param.to_s)}" if options[:anchor]

      rewritten_url
    end
  end
end
