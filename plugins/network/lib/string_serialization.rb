# fixing serialization of arrays of plain strings

class String
  def to_xml(options = {})
    require 'builder' unless defined?(Builder)
    xml = options[:builder] ||= Builder::XmlMarkup.new(options)
    xml.instruct! unless options[:skip_instruct]

    xml.tag! :string, self
  end unless method_defined?(:to_xml)
end
