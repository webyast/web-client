#
# spec file for package yast2-webclient-systemtime (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-webclient-systemtime
PreReq:         yast2-webclient >= 0.0.2
License:        GPL
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.0.6
Release:        0
Summary:        YaST2 - Webclient - SystemTime
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  ruby
BuildRequires:  yast2-webclient

#
%define pkg_user yast
%define plugin_name systemtime
#


%description
YaST2 - Webclient - UI for YaST-webservice in order to handle time and date.
Authors:
--------
    Stefan Schubert <schubi@opensuse.org>
    Josef Reidinger <jreidinger@suse.cz>
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

# remove .po files (no longer needed)
rm -rf $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/po
# search locale files
%find_lang yast_webclient_systemtime

%clean
rm -rf $RPM_BUILD_ROOT

%files -f yast_webclient_systemtime.lang
%defattr(-,root,root)
%dir /srv/www/%{pkg_user}
%dir /srv/www/%{pkg_user}/vendor
%dir /srv/www/%{pkg_user}/vendor/plugins
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/doc
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/locale
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/README
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/Rakefile
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/init.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/install.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/uninstall.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/lib
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config/rails_parent.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/doc/README_FOR_APP

%changelog
