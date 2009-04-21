class ControlpanelController < ApplicationController

  def index
    # no control panel for unlogged users
    if not logged_in?
      redirect_to :controller => :sessions, :action => :login
    end
    # retrieve the modle list
    @modules = modules
  end

  # this action generates the data for the available
  # modules based on the data of the service
  # which is available on session[controllers]
  # (bad name?)
  #
  # once we know which servces are there,
  # we match them with the available client
  # controllers
  def modules
    # the service -> client module matching can be made
    # mucho more intelligent later, for now, match
    # the modules we know about.
    client = []
    
    # we save the data here, that is how jimmac's template
    # expect the data (like fake-data.js)
    modules = map_modules

    respond_to do |format|
      format.html { } 
      format.xml  do
        render :xml => modules.to_xml, :location => "none"
        return
      end
      format.json do
        render :json => (params[:fake] == "1" ? self.fake_modules : modules.to_json), :location => "none"
        return
      end
    end
    # if no special format, just return modules
    modules
  end

  def map_modules
    modules = Hash.new
    if session.has_key?(:controllers)
      session[:controllers].each do |key, controller|
        mod = Hash.new

        mod[:title] = controller.description
        mod[:description] = controller.description
        mod[:title] = controller.description

        next if key.nil?
      
        case key
          when "services"
            mod[:icon] = 'icons/yast-online_update.png'
          when "language"
            mod[:icon] = 'icons/yast-language.png'
          when "users"
            mod[:icon] = 'icons/yast-users.png'
          when "permissions"
            mod[:icon] = 'icons/yast-security.png'
          when "patch_updates"
            mod[:icon] = 'icons/yast-package-manager.png'
          when "systemtime"
            mod[:icon] = 'icons/yast-ntp-client.png'
          else
            mod[:icon] = 'icons/yast-misc.png'
        end
        # TODO add the tags from the REST service that kkaempf
        # mentioned
        mod[:tags] = ['IP', 'network', 'IPv4', 'device', 'eth', 'wi-fi', 'ethernet', 'cable', 'card']
        # we dont have groups yet ups?
        mod[:groups] = ['network']
        mod[:url] = key
        mod[:favorite] = true

        modules[key] = mod
      end #each
    else
      logger.warn("No controllers in session")
    end #if controllers key
    modules
  end

  def fake_modules
    "({ 'network': {
    'title': 'Network',
    'description': 'Set up IPv4 network.',
    'icon': 'icons/yast-network.png',
    'tags': ['IP', 'network', 'IPv4', 'device', 'eth', 'wi-fi', 'ethernet', 'cable', 'card'],
    'groups': ['network'],
    'url':  '?page=fixme',
    'favorite':  true
  },'printers': {
    'title': 'Printers',
    'description': 'Configure local and remote printers.',
    'icon': 'icons/yast-printer.png',
    'tags': ['remote', 'local', 'print', 'printer', 'network', 'queue', 'lp', 'lpq', 'cups', 'daemon', 'IPP', 'lpd'],
    'groups': ['services','hardware'],
    'url':  '?page=printers',
    'favorite': true
  },'ldap-server': {
    'title': 'LDAP Server',
    'description': 'Lightweight Directory Access Protocol Server configuration',
    'icon': 'icons/yast-ldap-server.png',
    'url':  '?page=fixme',
    'tags': ['IP', 'ldap', 'directory', 'server', 'network', 'contact', 'address', 'user', 'management', 'addressbook'],
    'groups': ['services','network'],
  },'package-manager': {
    'title': 'Package Manager',
    'description': 'install, remove or update software.',
    'icon': 'icons/yast-package-manager.png',
    'tags': ['install', 'update', 'remove', 'uninstall', 'package', 'software','rpm','zypper'],
    'groups': ['software'],
    'url':  '?page=fixme',
    'favorite': true
  },'energy-saving': {
    'title': 'Energy Saving',
    'description': 'Configure power management &ndash; suspend, hibernation, hdd spin down.',
    'icon': 'icons/yast-pm.png',
    'tags': ['power', 'ups', 'battery', 'sleep', 'suspend', 'hibernation', 'spin down', 'resume'],
    'groups': ['hardware'],
    'url':  '?page=fixme',
    'favorite': true
  },'display': {
    'title': 'Display',
    'description': 'Set up monitors.',
    'icon': 'icons/yast-x11.png',
    'tags': ['monitor', 'display','resolution', 'color', 'depth', 'density', 'dpi', 'xinerama', 'dualhead'],
    'groups': ['hardware'],
    'url':  '?page=fixme',
    'favorite': true
  },'firewall': {
    'title': 'Firewall',
    'description': 'Protect your machine using a packet firewall.',
    'icon': 'icons/yast-firewall.png',
    'tags': ['tcp', 'udp', 'filter', 'rule', 'firewall', 'ip', 'iptables', 'ipfwadm', 'kernel'],
    'groups': ['security', 'network'],
    'url':  '?page=fixme',
    'favorite': true
  },'bluetooth': {
    'title': 'Bluetooth',
    'description': 'Configure the Bluetooth radio subsystem. Pair devices.',
    'icon': 'icons/yast-bluetooth.png',
    'tags': ['radio', 'bt', 'bluetooth', 'device'],
    'groups': ['services','hardware'],
    'url':  '?page=fixme',
    'favorite': true
  },'sound': {
    'title': 'Sound',
    'description': 'Set up audio devices.',
    'icon': 'icons/yast-sound.png',
    'tags': ['device', 'audio', 'sound', 'card', 'music', 'pcm'],
    'groups': ['hardware'],
    'url':  '?page=fixme',
    'favorite': true
  },'apparmor': {
    'title': 'AppArmor',
    'description': 'Configure Apparmor profiles.',
    'icon': 'icons/yast-apparmor.png',
    'tags': ['armor', 'application', 'security', 'apparmor', 'policy', 'restrict', 'rule'],
    'groups': ['security'],
    'url':  '?page=fixme'
  },'dns-server': {
    'title': 'DNS Server',
    'description': 'Provide a nameserver for your network.',
    'icon': 'icons/yast-dns-server.png',
    'tags': ['DNS', 'IP', 'name', 'resolution', 'nameserver', 'address'],
    'groups': ['services','network'],
    'url':  '?page=fixme'
  },'dhcp-server': {
    'title': 'DHCP Server',
    'description': 'Provide IP addresses on the network',
    'icon': 'icons/yast-dhcp-server.png',
    'tags': ['DHCP', 'IP', 'address', 'range', 'server', 'IPv4'],
    'groups': ['services','network'],
    'url':  '?page=fixme'
  },'dsl': {
    'title': 'DSL Modem',
    'description': 'configure the DSL modem device.',
    'icon': 'icons/yast-dsl.png',
    'tags': ['connection', 'internet', 'device', 'DSL', 'modem', 'ADSL'],
    'groups': ['hardware'],
    'url':  '?page=fixme'
  },'http-server': {
    'title': 'Web Server',
    'description': 'Configure your HTTP server (Apache).',
    'icon': 'icons/yast-http-server.png',
    'tags': ['web', 'HTTP', 'server', 'apache', 'httpd', 'internet', 'service'],
    'groups': ['services','network'],
    'url':  '?page=fixme'
  },'mail-server': {
    'title': 'Mail Server',
    'description': 'Configure the Message Transfer Agent (Sendmail).',
    'icon': 'icons/yast-mail-server.png',
    'tags': ['mail', 'email', 'e-mail', 'MTA', 'sendmail', 'server', 'messaging'],
    'groups': ['services', 'network'],
    'url':  '?page=fixme'    
  },'raid': {
    'title': 'Disk Array',
    'description': 'Set up a disk array (RAID).',
    'icon': 'icons/yast-raid.png',
    'tags': ['hdd', 'sata', 'ata', 'scsi', 'raid', 'array', 'disk', 'volume'],
    'groups': ['hardware'],
    'url':  '?page=fixme'
  },'partitioner': {
    'title': 'Disk Partitioning',
    'description': 'Set up partitions on your disk. Create logical volumes.',
    'icon': 'icons/yast-partitioning.png',
    'url':  '?page=fixme',
    'groups': ['hardware'],
    'tags': ['hdd', 'disk', 'partition', 'parted', 'fdisk', 'dev', 'device', 'volume', 'label', 'LVM']
  }
})"
  end
  
end
