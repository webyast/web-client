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
Requires:       lighttpd-mod_magnet, ruby-fcgi, sqlite, avahi-utils
PreReq:         lighttpd, rubygem-rake, rubygem-sqlite3, rubygem-rails == 2.1, ruby-gettext >= 1.93
License:        GPL
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        1.0.1
Release:        1
Summary:        YaST2 - Webclient 
Source:         www.tar.bz2
Source1:        cleanurl-v5.lua
Source2:        yastwc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby-devel
BuildArch:      noarch  

#
%define service_name yastwc
#


%description
YaST2 - Webclient - Web client for REST based YaST interface.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>
    Klaus Kaempf <kkaempf@opensuse.org>

%prep
%setup -q -n www

%build
(cd webclient; rake makemo)

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/yast
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/tmp
cp -a * $RPM_BUILD_ROOT/srv/www/yast
rm -rf $RPM_BUILD_ROOT/srv/www/yast/log/*

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

%clean
rm -rf $RPM_BUILD_ROOT

%post
#
#installing lighttpd server init scripts
#
test -r /usr/sbin/yastwc || { echo "Creating link /usr/sbin/yastwc";
        ln -s /usr/sbin/lighttpd /usr/sbin/yastwc; }
%fillup_and_insserv %{service_name}

#
# create database 
#
cd /srv/www/yast
rake db:migrate
chgrp lighttpd db db/*.sqlite*
chown lighttpd db db/*.sqlite*

%preun
%stop_on_removal %{service_name}

%postun
%restart_on_update %{service_name}
%{insserv_cleanup}
#remove link
if test -r /usr/sbin/yastwc ; then
  echo "/usr/sbin/yastwc already removed"
else
  echo "Removing link /usr/sbin/yastwc";
  rm /usr/sbin/yastwc
fi

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
/srv/www/yast/COPYING  
/srv/www/yast/INSTALL
/srv/www/yast/script  
/srv/www/yast/test  
/srv/www/yast/config  
/srv/www/yast/start.sh
%doc README* COPYING  
%attr(-,lighttpd,lighttpd) /srv/www/yast/log  
%attr(-,lighttpd,lighttpd) /srv/www/yast/tmp  
%config /etc/lighttpd/cleanurl-v5.lua  
%config(noreplace)  %{_sysconfdir}/init.d/%{service_name}
%{_sbindir}/rc%{service_name}

# %changelog  
# * Tue Nov 27 2008 schubi@suse.de  
# - initial  
