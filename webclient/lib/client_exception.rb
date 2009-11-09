require 'error_constructor'

#
# Exception class which support for remote
# exception information passed by the response body
#
# If you get an exception, and the exception has
# server side encoded information, you can create a
# ClientException from it and access the information
# in the same way you do with other kinds of exceptions
#
# If the exception has no encoded information, it will
# just forward every data
#
class ClientException < Exception
  include ErrorConstructor
  
  # creates an client exception from another
  # exception
  def initialize(excpt)
    # save the original exception
    @excpt = excpt
    @error_data = {}
    if backend_exception?
      Rails.logger.error "got exception : #{excpt.class} #{excpt.inspect}"
      Rails.logger.error "code: #{excpt.response.code}" if excpt.respond_to?(:response)
      Rails.logger.error "body: #{excpt.response.body}" if excpt.respond_to?(:response)
      Rails.logger.error "methods: #{excpt.request.methods.sort}" if excpt.respond_to?(:request)
      Rails.logger.error "original message: #{@excpt.message}"
      xml_data = Hash.from_xml(excpt.response.body) rescue {}
      @error_data.merge!(xml_data['error']) if xml_data.has_key?('error')

      Rails.logger.error "Exception is a bug: #{bug?}"
      
      # construct an exception from what we have
      @err_msg = construct_error(@error_data) if not @error_data.empty?
#handle 
      Rails.logger.error "new message: #{@err_msg}"
    end
  end
  
  # message of the exception, this is the translated
  # message for the error on the server side if the exception
  # happened there, or the local one if it is a normal exception
  def message
    return @err_msg unless @err_msg.blank?
    return @excpt.message if @excpt
  end

  # remote exception type as a string or "UNDEFINED"
  def backend_exception_type
    return @error_data['type'] if (@error_data && @error_data.has_key?('type'))
    "UNDEFINED"
  end
  
  # if the exception was produced because another exception
  # happened at the server side
  def backend_exception?
    @excpt and @excpt.is_a?(ActiveResource::ServerError) and
      @excpt.response.code.to_s =~ /.*503.*|.*500.*/
  end

  # if the exception is discarded to be a bug, like
  # a service not running on the server side
  def bug?
    return @error_data['bug'] if (@error_data && @error_data.has_key?('bug'))
    true
  end
  
  def backtrace
    return @error_data["backtrace"] if backend_exception_type == "GENERIC"
    return @excpt.backtrace if (@excpt && !@excpt.backtrace.blank?)
    []
  end

  # forward any other method
  #def method_missing(name, *args)
  #  @excpt.send(name, *args)
  #end
  
end
