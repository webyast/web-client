require 'test_helper'
require 'string_serialization'

class ArraySerializationTest < Test::Unit::TestCase

  def setup
    @options = {:skip_instruct => true, :indent => 0}
  end

  def test_string_array
    a = ["foo", "bar"]
    assert_equal "<strings type=\"array\"><string>foo</string><string>bar</string></strings>", a.to_xml(@options)
  end

  # avoid <nil-classes>
  def test_empty_array_of_strings
    a = []
    assert_equal "<strings type=\"array\"/>", a.to_xml(@options.merge(:root => "strings"))
  end

  # to make karmi happy ;-)
  def test_array_of_empty_strings
    a = ["", ""]
    assert_equal "<strings type=\"array\"><string></string><string></string></strings>", a.to_xml(@options)
  end

  # numbers still fail but we don't care
end
