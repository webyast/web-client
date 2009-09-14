
class System

    def initialize
	@client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.system')
	@sys = @client.find
    end

    def reboot
	@sys.reboot.active = true
	@sys.save
    end

    def shutdown
	@sys.shutdown.active = true
	@sys.save
    end

end
