#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require File.join(File.dirname(__FILE__),'..','test_helper')

class EulasTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    eulas_response = fixture "eulas.xml"
    sles_eula_response = fixture "sles_eula.xml"
    sles_eula_de_response = fixture "sles_eula_de.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.eulas" => "/eulas"
      mock.permissions "org.opensuse.yast.modules.eulas", { :read => true, :write => false }
      mock.get  "/eulas.xml", header, eulas_response, 200
      mock.get  "/eulas/1.xml", header, sles_eula_response, 200
      mock.get  "/eulas/1.xml?lang=de", header, sles_eula_de_response, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    eulas = Eulas.find :all
    assert eulas
    sles_eula = eulas[0]
    assert sles_eula
    assert_equal "SLES-11", sles_eula.name
  end

  def test_find_first
    sles_eula = Eulas.find 1
    assert sles_eula
    assert_equal "en", sles_eula.text_lang
  end

  def test_find_de
    de_eula = Eulas.find 1, :params => {:lang => "de"}
    assert de_eula
    assert_equal "de", de_eula.text_lang
  end
end
