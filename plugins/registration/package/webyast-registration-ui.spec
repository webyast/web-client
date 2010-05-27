#
# spec file for package webyast-registration-ui (Version 0.0.2)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-registration-ui
Recommends:     WebYaST(org.opensuse.yast.modules.registration.registration)
Provides:       yast2-webclient-registration = %{version}
Obsoletes:      yast2-webclient-registration < %{version}
PreReq:         yast2-webclient
License:        GPL v2 only
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        0.1.7
Release:        0
Summary:        WebYaST - Registration UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit rubygem-webyast-rake-tasks tidy

#
%define plugin_name registration
%define plugin_dir %{webyast_ui_dir}/vendor/plugins/%{plugin_name}
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit tidy
Summary:  Testsuite for webyast-registration-ui package

%description
WebYaST - Plugin providing UI for system registration.

Authors:
--------
    Stefan Schubert <schubi@novell.com>
    J. Daniel Schmidt <jdsn@novell.com>

%description testsuite
This package contains complete testsuite for webyast-registration-ui package.
It is only needed for verifying the functionality of the module
and it is not needed at runtime.

%prep
%setup -q -n www

%build
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
%find_lang webyast-registration-ui

%clean
rm -rf $RPM_BUILD_ROOT

%files -f webyast-registration-ui.lang
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%dir %{webyast_ui_dir}/vendor
%dir %{webyast_ui_dir}/vendor/plugins
%dir %{plugin_dir}
%dir %{plugin_dir}/doc
%dir %{plugin_dir}/locale
%{plugin_dir}/README
%{plugin_dir}/Rakefile
%{plugin_dir}/init.rb
%{plugin_dir}/install.rb
%{plugin_dir}/uninstall.rb
%{plugin_dir}/shortcuts.yml
%{plugin_dir}/app
%{plugin_dir}/tasks
%{plugin_dir}/config
%{plugin_dir}/doc/README_FOR_APP

%doc COPYING

%files testsuite
%defattr(-,root,root)
%{plugin_dir}/test



