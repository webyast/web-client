#
# spec file for package yast2-webclient (Version 0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-webclient
Requires:       lighttpd-mod_magnet, ruby-fcgi, sqlite
PreReq:         rubygem-rake, rubygem-sqlite3
PreReq:         rubygem-rails-2_3 = 2.3.4
PreReq:         rubygem-gettext_rails
%if 0%{?suse_version} == 0 || %suse_version > 1110
# 11.2 or newer
# Require startproc respecting -p, bnc#559534#c44
Requires:       sysvinit > 2.86-215.2
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
Autoreqprov:    on
Version:        0.0.28
Release:        0
Summary:        YaST2 - Webclient 
Source:         www.tar.bz2
Source1:        cleanurl-v5.lua
Source2:        yastwc
Source3:        check-create-certificate.pl
Source4:        webyast-ui
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby
BuildRequires:  sqlite rubygem-sqlite3
BuildRequires:  rubygem-rails-2_3 = 2.3.4
BuildRequires:  rubygem-gettext_rails, rubygem-yast2-webservice-tasks, rubygem-selenium-client
BuildRequires:  tidy
# we require the lighttpd user to be present when building the rpm
BuildRequires:  lighttpd
BuildArch:      noarch  
%define service_name yastwc
#


%description
YaST2 - Webclient - Web client for REST based YaST interface.

Authors:
--------
    Duncan Mac-Vicar Prett <dmacvicar@suse.de>
    Bjoern Geuken <bgeuken@suse.de>
    Stefan Schubert <schubi@opensuse.org>
    Klaus Kaempf <kkaempf@opensuse.org>

%prep
%setup -q -n www

%build
env LANG=en rake makemo

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/log
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp
cp -a * $RPM_BUILD_ROOT/srv/www/yast
rm -rf $RPM_BUILD_ROOT/srv/www/yast/log/*
rm -f $RPM_BUILD_ROOT/srv/www/yast/COPYING

#
# init script
#
%{__install} -d -m 0755                            \
    %{buildroot}%{_sbindir}

%{__install} -D -m 0755 %SOURCE2 \
    %{buildroot}%{_sysconfdir}/init.d/%{service_name}
%{__ln_s} -f %{_sysconfdir}/init.d/%{service_name} %{buildroot}%{_sbindir}/rc%{service_name}
#

# configure lighttpd web service
mkdir -p $RPM_BUILD_ROOT/etc/lighttpd
install -m 0644 %SOURCE1 $RPM_BUILD_ROOT/etc/lighttpd

mkdir -p $RPM_BUILD_ROOT/etc/lighttpd/certs
install -m 0755 %SOURCE3 $RPM_BUILD_ROOT/usr/sbin

# firewall service definition, bnc#545627
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services
install -m 0644 %SOURCE4 $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services

#  create empty tmp directory
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp/cache
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp/pids
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp/sessions
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp/sockets

%clean
rm -rf $RPM_BUILD_ROOT

%post
%fillup_and_insserv %{service_name}

#
# create database 
#
cd /srv/www/yast
RAILS_ENV=production rake db:migrate
chgrp lighttpd db db/*.sqlite* log log/*
chown lighttpd db db/*.sqlite* log log/*
chmod 700 db log
chmod 600 db/*.sqlite* log/*

%preun
%stop_on_removal %{service_name}

%postun
%restart_on_update %{service_name}
%{insserv_cleanup}

# restart yastwc on lighttpd update (bnc#559534)
%triggerin -- lighttpd
%restart_on_update %{service_name}

%files 
%defattr(-,root,root)
%dir /srv/www/yast 
/srv/www/yast/locale
/srv/www/yast/po
/srv/www/yast/vendor
/srv/www/yast/app  
/srv/www/yast/db  
/srv/www/yast/doc  
/srv/www/yast/lib  
/srv/www/yast/public  
/srv/www/yast/Rakefile  
/srv/www/yast/README*  
/srv/www/yast/INSTALL
/srv/www/yast/script  
/srv/www/yast/config  
/srv/www/yast/start.sh
%doc README* COPYING  
%attr(-,lighttpd,lighttpd) /srv/www/yast/log  
%attr(-,lighttpd,lighttpd) /srv/www/yast/tmp
%config /etc/lighttpd/cleanurl-v5.lua  
%config /etc/sysconfig/SuSEfirewall2.d/services/webyast-ui
%dir /etc/lighttpd/certs
/usr/sbin/check-create-certificate.pl
%config(noreplace)  %{_sysconfdir}/init.d/%{service_name}
%{_sbindir}/rc%{service_name}

%changelog  
* Tue Nov 27 2008 schubi@suse.de  
- initial  
