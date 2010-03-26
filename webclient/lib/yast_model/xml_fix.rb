module ActiveResource
  module Formats
    module XmlFormat
      def self.encode(hash,options={})
        XmlSerializer.serialize(hash,options)
      end
    end
  end
end


class XmlSerializer 
  def self.serialize(hash,options)
    root = options[:root]
    builder = options[:builder] || Builder::XmlMarkup.new(options)
    builder.instruct! unless options[:skip_instruct]
    serialize_value(root,hash,builder)
  end

  protected
  #place for all types for special serializing
  def self.serialize_value(name,value,builder)
    if value.is_a? Array
      builder.tag!(name,{:type => "array"}) do
        value.each do |v|
          serialize_value(name,v,builder)
        end
      end
    elsif value.is_a? Hash
    builder.tag!(name) do
        value.each do |k,v|
          serialize_value(k,v,builder)
        end
      end
    else
      type = XML_TYPE_NAMES[value.class.to_s]
      opts = {}
      opts[:type] = type if type
      #NOTE: can be optimalized for primitive types like boolean or numbers to avoid XML escaping
      builder.tag!(name,value.to_s,opts)
    end
  end

  XML_TYPE_NAMES = { #type conversion
      "Symbol"     => "symbol",
      "Fixnum"     => "integer",
      "Bignum"     => "integer",
      "BigDecimal" => "decimal",
      "Float"      => "float",
      "TrueClass"  => "boolean",
      "FalseClass" => "boolean",
      "Date"       => "date",
      "DateTime"   => "datetime",
      "Time"       => "datetime",
      "ActiveSupport::TimeWithZone" => "datetime"
    } unless defined?(XML_TYPE_NAMES)

end
