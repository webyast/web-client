require File.dirname(__FILE__) + '/../test_helper'
require 'client_exception'

def _(msg)
  msg
end

class ClientExceptionTest < ActiveSupport::TestCase

  def test_decode
    response = Struct.new("Response", :code, :body)
    body =<<EOF
<error>
  <type>NO_PERM</type>
  <description>A Message</description>
</error>
EOF

    body_unknown =<<EOF
<error>
  <type>UNKNOWN_ERROR</type>
  <description>A Message</description>
</error>
EOF

    # only 503 exceptions are backend exceptions
    server_error = ActiveResource::ServerError.new("message")
    server_error.stubs(:response).returns(response.new('503', body))
    client_exception = ClientException.new(server_error)
    assert client_exception.backend_exception?
    #assert_equal "", client_exception.message

    # a unknown backend exception would use the message from the
    # xml
    server_error = ActiveResource::ServerError.new("message")
    server_error.stubs(:response).returns(response.new('503', body_unknown))
    client_exception = ClientException.new(server_error)
    assert client_exception.backend_exception?
    assert_equal "A Message", client_exception.message

    server_error = ActiveResource::ServerError.new("message")
    server_error.stubs(:response).returns(response.new('502', body))
    client_exception = ClientException.new(server_error)
    assert ! client_exception.backend_exception?

    server_error = ActiveResource::ServerError.new("message")
    client_exception = ClientException.new(Exception.new("Hello!"))
    assert ! client_exception.backend_exception?
    assert_equal "Hello!", client_exception.message
    
  end
  
end

