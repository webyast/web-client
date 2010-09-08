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
Recommends:     WebYaST(org.opensuse.yast.system.repositories)
Recommends:     WebYaST(org.opensuse.yast.system.patches)
Provides:       yast2-webclient-patch_updates = %{version}
Obsoletes:      yast2-webclient-patch_updates < %{version}
# updated jQuery quicksearch plugin
PreReq:         yast2-webclient >= 0.1.17
Provides:       yast2-webclient:/srv/www/yast/app/controllers/patch_updates_controller.rb
License:	GPL v2 only
Group:          Productivity/Networking/Web/Utilities
URL:            http://en.opensuse.org/Portal:WebYaST
Autoreqprov:    on
Version:        0.2.9
Release:        0
Summary:        WebYaST - Software and Repository Management UI
Source:         www.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch
BuildRequires:  webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit rubygem-webyast-rake-tasks
BuildRequires:  tidy

#
%define plugin_name software
%define plugin_dir %{webyast_ui_dir}/vendor/plugins/%{plugin_name}
#


%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: webyast-base-ui-testsuite rubygem-mocha rubygem-test-unit tidy
Summary:  Testsuite for webyast-software-ui package

%description
WebYaST - Plugin providing UI for software management. This package contains patch installation
and repository management modules.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>
    Ladislav Slezak <lslezak@suse.cz>

%description testsuite
This package contains complete testsuite for webyast-software-ui package.
It is only needed for verifying the functionality of the module
and it is not needed at runtime.

%prep
%setup -q -n www

%build
rm -rf doc
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
%find_lang webyast-software-ui

%clean
rm -rf $RPM_BUILD_ROOT

%files -f webyast-software-ui.lang
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%dir %{webyast_ui_dir}/vendor
%dir %{webyast_ui_dir}/vendor/plugins
%dir %{plugin_dir}
%dir %{plugin_dir}/locale
%{plugin_dir}/README
%{plugin_dir}/Rakefile
%{plugin_dir}/init.rb
%{plugin_dir}/install.rb
%{plugin_dir}/uninstall.rb
%{plugin_dir}/shortcuts.yml
%{plugin_dir}/app
%{plugin_dir}/lib
%{plugin_dir}/config
%doc COPYING

%files testsuite
%defattr(-,root,root)
%{plugin_dir}/test


%changelog

