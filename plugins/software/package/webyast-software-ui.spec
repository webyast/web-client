#
# spec file for package webyast-software-ui (Version 0.1.x)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-software-ui
Provides:       yast2-webclient-patch_updates = %{version}
Obsoletes:      yast2-webclient-patch_updates < %{version}
# generate_error_messages helper
PreReq:         yast2-webclient >= 0.1.14
Provides:       yast2-webclient:/srv/www/yast/app/controllers/patch_updates_controller.rb
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.1.11
Release:        0
Summary:        YaST2 - Webclient - Software and Repository Management
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

#
%define pkg_user yast
%define plugin_name software
#


%description
YaST2 - Webclient - UI for YaST-webservice. This package contains patch installation
and repository management modules.
Authors:
--------
    Stefan Schubert <schubi@opensuse.org>
    Ladislav Slezak <lslezak@suse.cz>

%prep
%setup -q -n www

%build
rm -rf doc
export RAILS_PARENT=/srv/www/yast
env LANG=en rake makemo

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
cp -a * $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
rm -f $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/COPYING

# remove .po files (no longer needed)
rm -rf $RPM_BUILD_ROOT/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/po
# search locale files
%find_lang yast_webclient_patch_updates

%clean
rm -rf $RPM_BUILD_ROOT

%files -f yast_webclient_patch_updates.lang
%defattr(-,root,root)
%dir /srv/www/%{pkg_user}
%dir /srv/www/%{pkg_user}/vendor
%dir /srv/www/%{pkg_user}/vendor/plugins
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/locale
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/README
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/Rakefile
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/init.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/install.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/uninstall.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
%doc COPYING

%changelog

