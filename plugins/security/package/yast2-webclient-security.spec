#
# spec file for package yast2-webclient-security (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-webclient-security
Recommends:     WebYaST(org.opensuse.yast.system.security)
PreReq:         yast2-webclient
Provides:       yast2-webclient:/srv/www/yast/app/controllers/security_controller.rb
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.0.3
Release:        0
Summary:        YaST2 - Webclient - Security
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

#
%define pkg_user yast
%define plugin_name security
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit
Summary:  Testsuite for yast2-webclient-security package

%description
YaST2 Web user interface for security settings

%description testsuite
This package contains complete testsuite for yast2-webclient-security package.
It is only needed for verifying the functionality of the module
and it is not needed at runtime.

%prep
%setup -q -n www

%build
rm -rf doc
export RAILS_PARENT=/srv/www/yast
env LANG=en rake makemo

%check
%webyast_ui_check

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
%find_lang yast_webclient_security

%clean
rm -rf $RPM_BUILD_ROOT

# read the language files found by %find_lang from .lang file
%files -f yast_webclient_security.lang
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
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
#/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/test
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{webyast_ui_dir}/vendor/plugins/%{plugin_name}/test


