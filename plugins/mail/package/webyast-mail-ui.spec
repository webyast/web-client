#
# spec file for package webyast-mail-ui
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-mail-ui
Recommends:     WebYaST(org.opensuse.yast.modules.yapi.mailsettings)
Provides:       yast2-webclient-mailsettings = %{version}
Obsoletes:      yast2-webclient-mailsettings < %{version}
PreReq:         yast2-webclient >= 0.0.2
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.1.17
Release:        0
Summary:        WebYaST - Mail Settings UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit rubygem-webyast-rake-tasks
BuildRequires:  ruby tidy
BuildRequires:  yast2-webclient webyast-root-user-ui

#
%define pkg_user yast
%define plugin_name mail
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit
Summary:  Testsuite for webyast-mail-ui package

%description
WebYaST - Plugin providing UI for system mail settings

Authors:
--------
    Jiri Suchomel <jsuchome@novell.com>

%description testsuite
This package contains complete testsuite for webyast-mail-ui package.
It is only needed for verifying the functionality of the module
and it is not needed at runtime.

%prep
%setup -q -n www

%build
export RAILS_PARENT=/srv/www/yast
export LANG=en
rake makemo

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
%find_lang yast_webclient_mail

%clean
rm -rf $RPM_BUILD_ROOT

%files -f yast_webclient_mail.lang
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
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config/rails_parent.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/doc/README_FOR_APP
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{webyast_ui_dir}/vendor/plugins/%{plugin_name}/test


%changelog
