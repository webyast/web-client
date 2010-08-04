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
Version:        0.2.1
Release:        0
Summary:        WebYaST - users management UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit rubygem-webyast-rake-tasks
BuildRequires:  tidy

#
%define plugin_name users
%define plugin_dir %{webyast_ui_dir}/vendor/plugins/%{plugin_name}
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit tidy
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
mkdir -p $RPM_BUILD_ROOT/%{plugin_dir}
cp -a * $RPM_BUILD_ROOT/%{plugin_dir}
rm -f $RPM_BUILD_ROOT/%{plugin_dir}/COPYING

# remove .po files (no longer needed)
rm -rf $RPM_BUILD_ROOT/%{plugin_dir}/po

# search locale files
%find_lang webyast-users-ui

%clean
rm -rf $RPM_BUILD_ROOT

%files -f webyast-users-ui.lang
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%dir %{webyast_ui_dir}/vendor
%dir %{webyast_ui_dir}/vendor/plugins
%dir %{plugin_dir}
%dir %{plugin_dir}/config
%dir %{plugin_dir}/locale
%{plugin_dir}/README
%{plugin_dir}/Rakefile
%{plugin_dir}/init.rb
%{plugin_dir}/install.rb
%{plugin_dir}/uninstall.rb
%{plugin_dir}/shortcuts.yml
%{plugin_dir}/app
%{plugin_dir}/tasks
%{plugin_dir}/public
%{plugin_dir}/config/rails_parent.rb
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{plugin_dir}/test


