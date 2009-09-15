require 'test_helper'
require 'string_serialization'

# a stupid modification to see if passing a special builder works
class MyBuilder < Builder::XmlMarkup
  def tag! name, content
    super "my#{name}", content
  end
end

class StringSerializationTest < Test::Unit::TestCase

  def setup
    @options = {:skip_instruct => true}
  end

  def test_plain
    assert_equal "<string>foo</string>", "foo".to_xml(@options)
  end

  def test_full
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?><string>foo</string>", "foo".to_xml
  end

  def test_escaping
    assert_equal "<string>&amp;</string>", "&".to_xml(@options)
  end

  def test_special_builder
    my_builder = MyBuilder.new()
    assert_equal "<mystring>foo</mystring>", "foo".to_xml(@options.merge(:builder => my_builder))
  end

end
