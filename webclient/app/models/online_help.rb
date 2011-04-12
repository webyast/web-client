#--
# Webyast Webclient framework
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

require 'rubygems'
require 'nokogiri'
require 'open-uri'

class OnlineHelp
  def self.find(model)
    return OnlineHelp.parse(model)
  end
  
  def OnlineHelp.parse(model)
    html = open("http://doc.opensuse.org/products/other/WebYaST/webyast-user/cha.webyast.user.modules.html")
    doc = Nokogiri::HTML(html.read)
    doc.encoding = 'utf-8'

    unless doc.nil?
      doc.css('div.sect1').each do |link|
  	title = link.attributes['title'].text
	link.css('h2.title span.permalink').remove()
	link.css('a[alt="Permalink"]').remove()
	link.css('tr.head td:first').remove()

	if title.include? model
	  return link
  	end
      end
    end
  end
end
