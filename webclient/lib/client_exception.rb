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
      @error_data = Hash.from_xml(excpt.response.body) rescue {}
      # construct an exception from what we have
      @err_msg = construct_error(@error_data)
    end
  end
  
  # message of the exception, this is the translated
  # message for the error on the server side if the exception
  # happened there, or the local one if it is a normal exception
  def message
    return @err_msg unless  @err_msg.blank?
    return @excpt.message
  end

  # remote exception type as a symbol
  def backend_exception_type
    if error_data.has_key?('error')
      return error_data['error']['type'].to_sym if error_data['error'].has_key?('type')
    end
    return :exception
  end

  def backend_exception?
    @excpt.is_a?(ActiveResource::ServerError) and
      @excpt.response.code.to_s =~ /.*503.*/
  end
  
  def backtrace
    @excpt.backtrace
  end
    
end
