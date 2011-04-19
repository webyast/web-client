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
# bnc#634404
Recommends:     logrotate
Provides:       yast2-webclient = %{version}
Obsoletes:      yast2-webclient < %{version}
Requires:       ruby-fcgi, sqlite, syslog-ng, check-create-certificate
Requires: 	webyast-branding
PreReq:         rubygem-rake, rubygem-sqlite3
PreReq:         rubygem-rails-2_3 >= 2.3.8
PreReq:         rubygem-gettext_rails
PreReq:         yast2-runlevel
Provides:       webyast-language-ui = 0.1.2
Obsoletes:      webyast-language-ui <= 0.1.2

%if 0%{?suse_version} == 0 || %suse_version > 1110
# 11.2 or newer

%if 0%{?suse_version} > 1120
# since 11.3, they are in a separate subpackage
Requires:       sysvinit-tools
%else
# Require startproc respecting -p, bnc#559534#c44
Requires:       sysvinit > 2.86-215.2
%endif
%else
# 11.1 or SLES11
Requires:       sysvinit > 2.86-195.3.1
%endif
Requires:       nginx, rubygem-passenger-nginx, rubygem-nokogiri

License:        LGPL v2.1;ASLv2.0
Group:          Productivity/Networking/Web/Utilities
URL:            http://en.opensuse.org/Portal:WebYaST
Autoreqprov:    on
Version:        0.2.26
Release:        0
Summary:        WebYaST - base UI for system management
Source:         www.tar.bz2
Source2:        yastwc
Source4:        webyast-ui
Source5:	control_panel.yml
Source6:	webyast-ui.lr.conf
Source7:        nginx.conf
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby
BuildRequires:  sqlite rubygem-sqlite3
BuildRequires:  rubygem-rails-2_3 >= 2.3.8
BuildRequires:  rubygem-gettext_rails, rubygem-yast2-webservice-tasks, rubygem-selenium-client
BuildRequires:  tidy, rubygem-haml, rubygem-nokogiri
BuildArch:      noarch
BuildRequires:  rubygem-test-unit rubygem-mocha
BuildRequires:  nginx, rubygem-passenger-nginx
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

# configure lighttpd/nginx web service
mkdir -p $RPM_BUILD_ROOT/etc/lighttpd/certs

# configure nginx web service
mkdir -p $RPM_BUILD_ROOT/etc/yastwc/
install -m 0644 %SOURCE7 $RPM_BUILD_ROOT/etc/yastwc/
# create symlinks to nginx config files
ln -s /etc/nginx/fastcgi.conf $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/fastcgi_params $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/koi-utf $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/koi-win $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/mime.types $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/scgi_params $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/uwsgi_params $RPM_BUILD_ROOT/etc/yastwc
ln -s /etc/nginx/win-utf $RPM_BUILD_ROOT/etc/yastwc

# firewall service definition, bnc#545627
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services
install -m 0644 %SOURCE4 $RPM_BUILD_ROOT/etc/sysconfig/SuSEfirewall2.d/services

# logrotate configuration bnc#634404
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
install -m 0644 %SOURCE6 $RPM_BUILD_ROOT/etc/logrotate.d

#  create empty tmp directory
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/cache
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/pids
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/sessions
mkdir -p $RPM_BUILD_ROOT/%{webyast_ui_dir}/tmp/sockets

# install YAML config file
mkdir -p $RPM_BUILD_ROOT/etc/webyast/
cp %SOURCE5 $RPM_BUILD_ROOT/etc/webyast/

#create dummy update-script
mkdir -p %buildroot/var/adm/update-scripts
touch %buildroot/var/adm/update-scripts/%name-%version-%release-1

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# services will not be restarted correctly if
# the package name will changed while the update
# So the service will be restarted by an update-script
# which will be called AFTER the installation
if /bin/rpm -q yast2-webclient > /dev/null ; then
  echo "renaming yast2-webclient to webyast-base-ui"
  if /sbin/yast runlevel summary service=yastwc 2>&1|grep " 3 "|grep yastwc >/dev/null ; then
    echo "yastwc is inserted into the runlevel"
    echo "#!/bin/sh" > %name-%version-%release-1
    echo "/sbin/yast runlevel add service=yastwc" >> %name-%version-%release-1
    echo "/usr/sbin/rcyastwc restart" >> %name-%version-%release-1
  else
    if /usr/sbin/rcyastwc status > /dev/null ; then
      echo "yastwc is running"
      echo "#!/bin/sh" > %name-%version-%release-1
      echo "/usr/sbin/rcyastwc restart" >> %name-%version-%release-1
    fi
  fi
  if [ -f %name-%version-%release-1 ] ; then
    install -D -m 755 %name-%version-%release-1 /var/adm/update-scripts
    rm %name-%version-%release-1
    echo "Please check the service runlevels and restart WebYaST client with \"rcyastwc restart\" if the update has not been called with zypper,yast or packagekit"
  fi
fi
exit 0

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

# restart yastwc on nginx update (bnc#559534)
%triggerin -- nginx
%restart_on_update %{webyast_ui_service}

%files
%defattr(-,root,root)
%dir /etc/yastwc
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
%dir /etc/lighttpd
%dir /etc/lighttpd/certs
%config %{_sysconfdir}/init.d/%{webyast_ui_service}
%{_sbindir}/rc%{webyast_ui_service}
%dir /etc/webyast/
%config /etc/webyast/control_panel.yml

#nginx stuff
%config(noreplace) /etc/yastwc/nginx.conf
%config /etc/yastwc/fastcgi.conf
%config /etc/yastwc/fastcgi_params
%config /etc/yastwc/koi-utf
%config /etc/yastwc/koi-win
%config /etc/yastwc/mime.types
%config /etc/yastwc/scgi_params
%config /etc/yastwc/uwsgi_params
%config /etc/yastwc/win-utf

#logrotate configuration file
%config(noreplace) /etc/logrotate.d/webyast-ui.lr.conf

### exclude css, icons and images 
%exclude %{webyast_ui_dir}/public/stylesheets
%exclude %{webyast_ui_dir}/public/icons
%exclude %{webyast_ui_dir}/public/images

%ghost %attr(755,root,root) /var/adm/update-scripts/%name-%version-%release-1

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
