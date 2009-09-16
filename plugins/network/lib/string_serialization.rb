# fixing serialization of arrays of plain strings

# DO NOT USE, it breaks Hash#to_xml:
# h = {"foo" => "bar", "baz" => "qux"}
# before:
# <hash>
#   <baz>qux</baz>
#   <foo>bar</foo>
# </hash>
# after:
# <hash>
#   <string>qux</string>
#   <string>bar</string>
# </hash>

class String
  def to_xml(options = {})
    require 'builder' unless defined?(Builder)
    xml = options[:builder] ||= Builder::XmlMarkup.new(options)
    xml.instruct! unless options[:skip_instruct]

    xml.tag! :string, self
  end unless method_defined?(:to_xml)
end
