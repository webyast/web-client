#
# spec file for package webyast-time-ui (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-example-ui
Requires(pre):  yast2-webclient >= 0.0.2
License:        GPL-2.0	
Group:          Productivity/Networking/Web/Utilities
URL:            http://en.opensuse.org/Portal:WebYaST
Autoreqprov:    on
Version:        0.2.11
Release:        0
Summary:        WebYaST - example UI plugin
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  rubygem-webyast-rake-tasks webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit
BuildRequires:  ruby tidy
BuildRequires:  yast2-webclient

#
%define plugin_name example
%define plugin_dir %{webyast_ui_dir}/vendor/plugins/%{plugin_name}
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit tidy
Summary:  Testsuite for %{plugin_name} package

%description
WebYaST - Example Plugin as a framework for new plugins.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>

%description testsuite
This package contains complete testsuite for %{plugin_name} package.
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
%find_lang webyast-example-ui

%clean
rm -rf $RPM_BUILD_ROOT

%files -f webyast-example-ui.lang
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%dir %{webyast_ui_dir}/vendor
%dir %{webyast_ui_dir}/vendor/plugins
%dir %{plugin_dir}
%dir %{plugin_dir}/config
%{plugin_dir}/locale
%{plugin_dir}/Rakefile
%{plugin_dir}/shortcuts.yml
%{plugin_dir}/app
%{plugin_dir}/config/rails_parent.rb
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{plugin_dir}/test


%changelog
