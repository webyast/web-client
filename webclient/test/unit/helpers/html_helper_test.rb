#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require File.dirname(__FILE__) + '/../../test_helper'

class HtmlHelperTest < ActiveSupport::TestCase
  include ViewHelpers::HtmlHelper

  # test jQuery selector name escaping
  def test_safe_id

    # test nil behavior
    assert_equal nil, safe_id(nil)

    # regexp for safe_id() result - only ASCII letters, numbers, '-' and '_'
    r = /^[-a-zA-Z0-9_]*$/

    # test empty input
    assert_match r, safe_id('')

    # test symbols
    assert_match r, safe_id('!@#$%^&*()_+}{":?><\'')

    # test some UTF-8 characters
    assert_match r, safe_id('ěščřžýáíéůúÁŠČŘÝÁÍÉŮÚ')

    # test plain ASCII
    assert_match r, safe_id('plain ASCII input')

  end

end
