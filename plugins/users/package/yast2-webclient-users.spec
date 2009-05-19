#
# spec file for package yast2-webclient-users (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-webclient-users
PreReq:         yast2-webclient
Provides:       yast2-webclient:/srv/www/yast/app/controllers/users_controller.rb
License:        GPL
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.0.1
Release:        0
Summary:        YaST2 - Webclient - Users
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

#
%define pkg_user yast
%define plugin_name users
#


%description
YaST2 - Webclient - UI for YaST-webservice in order to handle users settings.
Authors:
--------
    Stefan Schubert <schubi@opensuse.org>

%prep
%setup -q -n www

%build
(rake makemo)

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
cp -a * $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}


%clean
rm -rf $RPM_BUILD_ROOT

%files 
%defattr(-,root,root)
%dir /srv/www/%{pkg_user}
%dir /srv/www/%{pkg_user}/vendor
%dir /srv/www/%{pkg_user}/vendor/plugins
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/MIT-LICENSE
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/README
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/Rakefile
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/init.rb
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/install.rb
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/uninstall.rb
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/test
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/locale
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/po
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
%config /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config/routes.rb

