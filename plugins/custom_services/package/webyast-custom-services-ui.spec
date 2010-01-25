#
# spec file for package yast2-webclient-services (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-custom-services-ui
Provides:       yast2-webclient-custom-services = %{version}
Obsoletes:      yast2-webclient-custom-services < %{version}
PreReq:         yast2-webclient
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.0.6
Release:        0
Summary:        YaST2 - Webclient - Custom Services
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

Requires:	yast2-webclient-services

#
%define pkg_user yast
%define plugin_name custom_services
#


%description
YaST2 - Webclient - UI for YaST-webservice in order to handle custom service(s).
Authors:
--------


%prep
%setup -q -n www

%build
export RAILS_PARENT=/srv/www/yast
env LANG=en rake makemo

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
cp -a * $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
rm -f $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/COPYING

%clean
rm -rf $RPM_BUILD_ROOT

%files 
%defattr(-,root,root)
%dir /srv/www/%{pkg_user}
%dir /srv/www/%{pkg_user}/vendor
%dir /srv/www/%{pkg_user}/vendor/plugins
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/README
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/Rakefile
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/public
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/po
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/locale
%doc COPYING
