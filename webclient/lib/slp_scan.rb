# helper scan for hosts via slp
module Slp
  require 'uri'
  
  def scan
    hosts = []
    # make output parseable + terminate 
    services = `avahi-browse _yastws._tcp -t -p --no-db-lookup`
    
    # +;eth0;IPv4;YaST\032Webservice\032http\058\047\047aries\.suse\.de\0588080;_yastws._tcp;local
    
    services.each do |s|
      sp = s.split ";"
      next unless sp[0] == "+"
      name = sp[3]
      sp = name.split "\\"
      name = ""
      sp.each do |s|
	if s.length > 2
	  val = s[0,3].to_i
	  if val > 0
	    s = val.chr + (s[3..-1] || "")
	  end
	  name << s
	end
      end
      url = name.split(" ").pop || name

      if Host.find(:first, :conditions => "url = '#{url}'").nil?
         host = Host.new({"url"=>url, "description"=>"via network scan"})
	 next unless host
	 host.save
         hosts << host
      end
    end
    hosts
  end
end
