({ 'network': {
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
})