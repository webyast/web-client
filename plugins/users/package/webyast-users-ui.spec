#
# spec file for package yast2-webclient-users (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:		webyast-users-ui
Recommends:     WebYaST(org.opensuse.yast.modules.yapi.users)
Recommends:     WebYaST(org.opensuse.yast.modules.yapi.groups)
Provides:       yast2-webclient-users = %{version}
Obsoletes:      yast2-webclient-users < %{version}
# updated jQuery quicksearch plugin
PreReq:         yast2-webclient >= 0.1.17
PreReq:         webyast-users-ws >= 0.1.6
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.1.25
Release:        0
Summary:        WebYaST - users management UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit rubygem-webyast-rake-tasks

#
%define pkg_user yast
%define plugin_name users
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit
Summary:  Testsuite for webyast-users-ui package

%description
WebYaST - Plugin providing UI for user management.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>

%description testsuite
This package contains complete testsuite for webyast-users-ui package.
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
%find_lang yast_webclient_users

%clean
rm -rf $RPM_BUILD_ROOT

%files -f yast_webclient_users.lang
%defattr(-,root,root)
%dir /srv/www/%{pkg_user}
%dir /srv/www/%{pkg_user}/vendor
%dir /srv/www/%{pkg_user}/vendor/plugins
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/config
%dir /srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/locale
/srv/www/yast/vendor/plugins/%{plugin_name}/config/rails_parent.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/README
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/Rakefile
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/init.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/install.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/uninstall.rb
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/app
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/tasks
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/shortcuts.yml
/srv/www/%{pkg_user}/vendor/plugins/%{plugin_name}/public
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{webyast_ui_dir}/vendor/plugins/%{plugin_name}/test


