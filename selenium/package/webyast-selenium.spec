#
# spec file for package webyast-selenium (Version 1.0.1)
#
# Copyright (c) 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           webyast-selenium
Provides:       yast2-webclient-selenium = %{version}
Obsoletes:      yast2-webclient-selenium < %{version}
Autoreqprov:    on
Version:        1.0.1
Release:        0
Group:          Productivity/Networking/Web/Utilities
License:        Apache License v. 2.0
Summary:        YaST2 - Webclient - Selenium Remote Control
Url:            http://seleniumhq.org
Requires:       rubygem-selenium-client
Requires:       jre
BuildArch:      noarch
BuildRequires:	fastjar
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source:         www.tar.bz2

%description
This package contains Selenium Remote Control component which
is used for automated UI testing.


%prep
%setup -q -n www

%build

%install

#
# Install all parts.
#
mkdir -p $RPM_BUILD_ROOT/srv/www/yast/vendor/selenium-remote-control
cp -a * $RPM_BUILD_ROOT/srv/www/yast/vendor/selenium-remote-control

# don't package the Rakefile
rm $RPM_BUILD_ROOT/srv/www/yast/vendor/selenium-remote-control/Rakefile

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
%dir /srv/www/yast
%dir /srv/www/yast/vendor
/srv/www/yast/vendor/selenium-remote-control
%doc README*

%changelog
