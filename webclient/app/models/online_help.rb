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