#
# spec file for package webyast-time-ui (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-time-ui
Recommends:     WebYaST(org.opensuse.yast.modules.yapi.time)
Recommends:     WebYaST(org.opensuse.yast.modules.yapi.ntp)
Provides:       yast2-webclient-systemtime = %{version}
Obsoletes:      yast2-webclient-systemtime < %{version}
Requires(pre):  yast2-webclient >= 0.0.2
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
URL:            http://en.opensuse.org/Portal:WebYaST
Autoreqprov:    on
Version:        0.2.3
Release:        0
Summary:        WebYaST - time management UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  rubygem-webyast-rake-tasks
BuildRequires:  ruby
BuildRequires:  yast2-webclient

#
%define plugin_name time
%define plugin_dir %{webyast_ui_dir}/vendor/plugins/%{plugin_name}
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit tidy
BuildRequires: webyast-services-ui-testsuite tidy
Summary:  Testsuite for webyast-time-ui package

%description
WebYaST - Plugin providing UI for handling of time zone, system time and date.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>
    Josef Reidinger <jreidinger@suse.cz>

%description testsuite
This package contains complete testsuite for webyast-time-ui package.
It is only needed for verifying the functionality of the module
and it is not needed at runtime.

%prep
%setup -q -n www

%build
export RAILS_PARENT=%{webyast_ui_dir}
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
%find_lang webyast-time-ui

%clean
rm -rf $RPM_BUILD_ROOT

%files -f webyast-time-ui.lang
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%dir %{webyast_ui_dir}/vendor
%dir %{webyast_ui_dir}/vendor/plugins
%dir %{plugin_dir}
%dir %{plugin_dir}/config
%dir %{plugin_dir}/doc
%dir %{plugin_dir}/locale
%{plugin_dir}/README
%{plugin_dir}/Rakefile
%{plugin_dir}/init.rb
%{plugin_dir}/install.rb
%{plugin_dir}/uninstall.rb
%{plugin_dir}/shortcuts.yml
%{plugin_dir}/app
%{plugin_dir}/lib
%{plugin_dir}/config/rails_parent.rb
%{plugin_dir}/doc/README_FOR_APP
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{plugin_dir}/test


%changelog
