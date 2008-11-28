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
PreReq:         lighttpd, rubygem-rake, rubygem-sqlite3, rubygem-rails
License:        GPL
Group:          Productivity/Networking/Web/Utilities
Autoreqprov:    on
Version:        1.0.0
Release:        1
Summary:        YaST2 - Webclient 
Source:         www.tar.bz2
Source1:        cleanurl-v5.lua
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby-devel
BuildArch:      noarch  


%description
YaST2 - Webclient - Web client for REST based YaST interface.

Authors:
--------
    Stefan Schubert <schubi@opensuse.org>

%prep
%setup -q -n www

%build

%install

#
# Install all web and frontend parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/yast
cp -a * $RPM_BUILD_ROOT/srv/www/yast
rm $RPM_BUILD_ROOT/srv/www/yast/log/*

# configure lighttpd web service
mkdir -p $RPM_BUILD_ROOT/etc/lighttpd
install -m 0644 %SOURCE1 $RPM_BUILD_ROOT/etc/lighttpd

%clean
rm -rf $RPM_BUILD_ROOT

%post
#
# create database 
#
cd /srv/www/yast
rake db:migrate
chgrp lighttpd db db/*.sqlite*
chown lighttpd db db/*.sqlite*

%files 
%defattr(-,root,root)
%dir /srv/www/yast  
/srv/www/yast/app  
/srv/www/yast/db  
/srv/www/yast/doc  
/srv/www/yast/lib  
/srv/www/yast/public  
/srv/www/yast/Rakefile  
/srv/www/yast/README*  
/srv/www/yast/COPYING  
/srv/www/yast/script  
/srv/www/yast/test  
/srv/www/yast/config  
%doc README* COPYING  
%attr(-,lighttpd,lighttpd) /srv/www/yast/log  
%attr(-,lighttpd,lighttpd) /srv/www/yast/tmp  
%config /etc/lighttpd/cleanurl-v5.lua  

# %changelog  
# * Tue Nov 27 2008 schubi@suse.de  
# - initial  
