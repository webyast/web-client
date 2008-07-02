require 'systemtime'

class SystemTimeController < ApplicationController

  def index
    #t = SystemTime.find(:all, :from => '/system/time', :element_name => 'system-time')
    #render :xml => t.to_xml

    servers = Services::Ntp::Config::Server.find(:all)

  end

end
