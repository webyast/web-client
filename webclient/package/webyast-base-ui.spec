#
# spec file for package webyast-base-ui (Version 0.1.x)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           webyast-base-ui
Recommends:     WebYaST(org.opensuse.yast.modules.basesystem)
Provides:       yast2-webclient = %{version}
Obsoletes:      yast2-webclient < %{version}
Requires:       lighttpd-mod_magnet, ruby-fcgi, sqlite, syslog-ng, check-create-certificate
Requires: 	webyast-branding
PreReq:         rubygem-rake, rubygem-sqlite3
PreReq:         rubygem-rails-2_3 >= 2.3.4
PreReq:         rubygem-gettext_rails

%if 0%{?suse_version} == 0 || %suse_version > 1110
# 11.2 or newer

%if 0%{?suse_version} > 1120
# since 11.3, they are in a separate subpackage
Requires:       sysvinit-tools
%else
# Require startproc respecting -p, bnc#559534#c44
Requires:       sysvinit > 2.86-215.2
%endif
# Require lighttpd whose postun does not mass kill, bnc#559534#c19
# (Updating it later does not work because postun uses the old
# version.)
PreReq:         lighttpd > 1.4.20-3.6
%else
# 11.1 or SLES11
Requires:       sysvinit > 2.86-195.3.1
PreReq:         lighttpd > 1.4.20-2.29.1
%endif

License:        LGPL v2.1;ASLv2.0
Group:          Productivity/Networking/Web/Utilities
URL:            http://en.opensuse.org/Portal:WebYaST
Autoreqprov:    on
Version:        0.2.14
Release:        0
Summary:        WebYaST - base UI for system management
Source:         www.tar.bz2
Source2:        yastwc
Source4:        webyast-ui
Source5:	control_panel.yml
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby
BuildRequires:  sqlite rubygem-sqlite3
BuildRequires:  rubygem-rails-2_3 >= 2.3.4
BuildRequires:  rubygem-gettext_rails, rubygem-yast2-webservice-tasks, rubygem-selenium-client
BuildRequires:  tidy, rubygem-haml
# we require the lighttpd user to be present when building the rpm
BuildRequires:  lighttpd
BuildArch:      noarch
BuildRequires:  rubygem-test-unit rubygem-mocha
#

%description
WebYaST - Provides core web client for WebYaST service.
Without plugins has only very limited configuration options.

Authors:
--------
    Duncan Mac-Vicar Prett <dmacvicar@suse.de>
    Bjoern Geuken <bgeuken@suse.de>
    Stefan Schubert <schubi@opensuse.org>
    Klaus Kaempf <kkaempf@opensuse.org>
    Josef Reidinger <jreidinger@suse.cz>

%package testsuite
Group:    Productivity/Networking/Web/Utilities
Requires: %{name} = %{version}
Requires: rubygem-mocha rubygem-test-unit tidy
Summary:  Testsuite for webyast-base-ui package

%description testsuite
This package contains complete testsuite for webyast-base-ui package.
It is only needed for verifying the functionality of the package
and it is not needed at runtime.

%package branding-default
Group:    Productivity/Networking/Web/Utilities
Provides: webyast-branding
Requires: %{name} = %{version}
#Requires: rubygem-mocha rubygem-test-unit tidy
Summary:  Branding package for webyast-base-ui package

%description branding-default
This package contains css, icons and images for webyast-base-ui package.

%prep
%setup -q -n www

%build
env LANG=en rake makemo
rake sass:update
rake js:base
rm -r app/sass

%check
# run the testsuite
RAILS_ENV=test rake db:migrate
RAILS_ENV=test rake test

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/log
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp
cp -a * $RPM_BUILD_ROOT/%{webyast_ui_dir}
rm -rf $RPM_BUILD_ROOT/%{webyast_ui_dir}/log/*
rm -rf $RPM_BUILD_ROOT/%{webyast_ui_dir}/po
rm -f $RPM_BUILD_ROOT/%{webyast_ui_dir}/COPYING

#
# init script
#
%{__install} -d -m 0755                            \
    %{buildroot}%{_sbindir}

%{__install} -D -m 0755 %SOURCE2 \
    %{buildroot}%{_sysconfdir}/init.d/%{webyast_ui_service}
%{__ln_s} -f %{_sysconfdir}/init.d/%{webyast_ui_service} %{buildroot}%{_sbindir}/rc%{webyast_ui_service}
#

# configure lighttpd web service
mkdir -p $RPM_BUILD_ROOT/etc/lighttpd/certs

# firewall service definition, bnc#545627
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services
install -m 0644 %SOURCE4 $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services

#  create empty tmp directory
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/cache
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/pids
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/sessions
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/sockets

# install YAML config file
mkdir -p $RPM_BUILD_ROOT/etc/webyast/
cp %SOURCE5 $RPM_BUILD_ROOT/etc/webyast/

%clean
rm -rf $RPM_BUILD_ROOT

%post
%fillup_and_insserv %{webyast_ui_service}

#
# create database
#
cd %{webyast_ui_dir}
RAILS_ENV=production rake db:migrate
chgrp %{webyast_ui_user} db db/*.sqlite* log log/*
chown %{webyast_ui_user} db db/*.sqlite* log log/*
chmod 700 log
chmod 755 db
chmod 600 db/*.sqlite* log/*

%preun
%stop_on_removal %{webyast_ui_service}

%postun
%restart_on_update %{webyast_ui_service}
%{insserv_cleanup}

# restart yastwc on lighttpd update (bnc#559534)
%triggerin -- lighttpd
%restart_on_update %{webyast_ui_service}

%files
%defattr(-,root,root)
%dir %{webyast_ui_dir}
%{webyast_ui_dir}/locale
%{webyast_ui_dir}/vendor
%{webyast_ui_dir}/app
%{webyast_ui_dir}/db
%{webyast_ui_dir}/doc
%{webyast_ui_dir}/lib
%{webyast_ui_dir}/public
%{webyast_ui_dir}/Rakefile
%{webyast_ui_dir}/README*
%{webyast_ui_dir}/INSTALL
%{webyast_ui_dir}/script
%{webyast_ui_dir}/config
%config %{webyast_ui_dir}/config/initializers/session_store.rb
%{webyast_ui_dir}/start.sh
%doc README* COPYING
%attr(-,%{webyast_ui_user},%{webyast_ui_user}) %{webyast_ui_dir}/log
%attr(-,%{webyast_ui_user},%{webyast_ui_user}) %{webyast_ui_dir}/tmp
%attr(-,%{webyast_ui_user},root) %{webyast_ui_dir}/public/javascripts
%config /etc/sysconfig/SuSEfirewall2.d/services/webyast-ui
%dir /etc/lighttpd/certs
%config(noreplace)  %{_sysconfdir}/init.d/%{webyast_ui_service}
%{_sbindir}/rc%{webyast_ui_service}
%dir /etc/webyast/
%config /etc/webyast/control_panel.yml

#logrotate configuration file
%config(noreplace) /etc/logrotate.d/webyast-ui.lr

### exclude css, icons and images 
%exclude %{webyast_ui_dir}/public/stylesheets
%exclude %{webyast_ui_dir}/public/icons
%exclude %{webyast_ui_dir}/public/images

%files testsuite
%defattr(-,root,root)
%{webyast_ui_dir}/test

%files branding-default
%defattr(-,root,root)
### include css, icons and images 
%{webyast_ui_dir}/public/stylesheets
%{webyast_ui_dir}/public/icons
%{webyast_ui_dir}/public/images

%changelog
