#
# spec file for package rubygem-locale_rails (Version 2.0.0)
#
# Copyright (c) 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild
Name:           rubygem-locale_rails
Version:        2.0.0
Release:        0
%define mod_name locale_rails
#
Group:          Development/Languages/Ruby
License:        GPLv2+ or Ruby
#
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  rubygems_with_buildroot_patch
Requires:       rubygems >= 1.2.0
BuildRequires:  rubygem-locale >= 2.0.0
Requires:       rubygem-locale >= 2.0.0
Provides:       ruby-gettext:%{_libdir}/ruby/vendor_ruby/1.8/gettext/active_record.rb
#
Url:            http://locale.rubyforge.org/
Source:         %{mod_name}-%{version}.gem
#
Summary:        Ruby-Locale for Ruby on Rails is the pure ruby library which provides basic functions for localization based on Ruby-Locale
%description
Ruby-Locale for Ruby on Rails is the pure ruby library which provides basic functions for localization.

%prep
%build
%install
%gem_install %{S:0}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libdir}/ruby/gems/%{rb_ver}/cache/%{mod_name}-%{version}.gem
%{_libdir}/ruby/gems/%{rb_ver}/gems/%{mod_name}-%{version}/
%{_libdir}/ruby/gems/%{rb_ver}/specifications/%{mod_name}-%{version}.gemspec
%doc %{_libdir}/ruby/gems/%{rb_ver}/doc/%{mod_name}-%{version}/

%changelog
