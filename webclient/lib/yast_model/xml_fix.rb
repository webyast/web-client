class Array
  def to_xml(options = {})
    require 'builder' unless defined?(Builder)

    options = options.dup
    options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize : "array"
    options[:children] ||= options[:root].singularize
    options[:indent]   ||= 2
    options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])

    root     = options.delete(:root).to_s
    children = options.delete(:children)

    if !options.has_key?(:dasherize) || options[:dasherize]
      root = root.dasherize
    end

    options[:builder].instruct! unless options.delete(:skip_instruct)

    opts = options.merge({ :root => children })

    xml = options[:builder]
    if empty?
      xml.tag!(root, options[:skip_types] ? {} : {:type => "array"})
    else
      xml.tag!(root, options[:skip_types] ? {} : {:type => "array"}) {
        yield xml if block_given?
        each do |e|
          if e.respond_to? :to_xml
            e.to_xml(opts.merge({ :skip_instruct => true }))
          else
            xml.tag!(children,e.to_s)
          end
        end
      }
    end
  end
end
