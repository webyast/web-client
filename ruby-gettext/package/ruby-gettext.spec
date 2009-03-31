#
# spec file for package ruby-gettext (Version 1.10.0)
#
# Copyright (c) 2007 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           ruby-gettext
Version:        1.93.0
Release:        0
%define pkg_version 1.93.0
#
Group:          Development/Languages/Ruby
License:        Other uncritical OpenSource License
#
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  ruby-devel ruby-racc
%if 0%{?with_tests}
# i am not sure we want to make the package depending on rails just for the testsuite
BuildRequires:  rubygem-rails
%endif
#
URL:            http://ponx.s5.xrea.com/hiki/ruby-gettext.html
Source:         ruby-gettext-%{version}.tar.bz2
Source1:        ruby-gettext-rpmlintrc
#
Summary:        Native Language Support for Ruby

%description
Ruby-GetText is a Native Language Support Library and Tools
which is modeled after GNU gettext package, but is not a wrapper of GNU
GetText.



Authors:
--------
    Masao Mutoh <mutoh@highway.ne.jp>

%prep
%setup -n %{name}

%build
ruby -rvendor-specific setup.rb config
ruby -rvendor-specific setup.rb setup
%if 0%{?with_tests}

%check
pushd test
%{_buildshell} test.sh
popd
%endif

%install
ruby -rvendor-specific setup.rb install --prefix="%{buildroot}"
%find_lang rgettext
%find_lang rails
%{__cat} rails.lang >> rgettext.lang

%clean
%{__rm} -rf %{buildroot}

%files -f rgettext.lang
%defattr(-,root,root,-)
%{_bindir}/*
%{_libdir}/ruby/vendor_ruby/%{rb_ver}/gettext*
%{_libdir}/ruby/vendor_ruby/%{rb_ver}/locale*
%doc  COPYING* README* NEWS ChangeLog samples/ test/

%changelog
* Sun Aug 05 2007 - mrueckert@suse.de
- update to version 1.10.0:
  * Support Vietnamese(vi), Bosnian(bs), Croatian(hr), Norwegian(nb)
  * Cache messages. Both _() and n_() become 1.3-1.8 times faster
  than older version.
  * Add GetText.ns_()
  * Fix bugs.
  * Enhance to support Ruby on Rails.
  * Work with script/generate scaffold_resource.
  * error_messages_for accepts plural models.
  * Support Action/Fragment caching.
- fixed a few rpmlint warnings and ignore a few of them
* Tue May 22 2007 - mrueckert@suse.de
- update to version 1.9.0:
  * Support Catalan(ca), Esperanto(eo)
  * Update translations: zh_CN, zh_TW, cs, nl, en, de, el, es, ja,
  ko, pt_BR, ru.
  * Support Ruby on Rails-1.2.1.
  * Code cleanupand improved. Fixed bugs.
* Sat Sep 30 2006 - mrueckert@suse.de
- update to version 1.8.0:
  * Support Chinese(Taiwan: zh_TW), Estonian(et: rails.po only)
  * Add GetText.bindtextdomain_to(klass, domainname),
  .textdomain_to(klass, domainname)
  * rgettext supports -r, -d options.
  '-r' is to set an option parser. -d is for debugging mode.
  (e.g.) $ rgettext -r fooparser test.foo
  * Update translations: pt_BR, de, zh_TW,
  * Code cleanup, fixed bugs.
  * Enhance to support Ruby on Rails.
  * init_gettext finds mo-files in
  /vendor/plugins/{plugin_name}/locale which has app/controller
  directories such as Rails Engines. And init_gettext accepts
  :locale_path option to be able to set the locale path manually.
  * init_gettext manages plural textdomains.
  * Add before_init_gettext, after_init_gettext methods like as
  before/after_filter.
  * Speed up(the sample blog is 1.5 times faster).
  * gettext/active_record.rb from gettext/rails.rb.
  * ActiveRecord::Validations is set the app's textdomain in
  init_gettext.  It means the class which includes
  ActiveRecord::Validtaions are localized with the app's
  textdomain. e.g.) You can use gettext methods in the
  subclass of ActiveForm[1]
  http://www.realityforge.org/svn/code/active-form/trunk/
  * Works rails edge again
  (http://dev.rubyonrails.org/ticket/5810)
- install into vendor_ruby
* Wed Jul 19 2006 - mrueckert@suse.de
- Update to version 1.7.0:
  * GetText.current_textdomain_info for debuging
  * Fixed bugs, code cleanup.
  * Update translations
  * Chinese(zh), Czech(cs), Dutch(nl), English(default), French(fr)
  Spanish(es), Japanese(ja), Korean(ko), Russian(ru)
  * Improve to support Ruby on Rails
  * Localize ActionView::Helpers::DateHelper.distance_of_time_in_words.
  * Localize #error_message_on.
  * Add ActiveRecord::Base.untranslate, .untranslate_all to prevend to
  translate columns.
* Sat Jun 10 2006 - mrueckert@suse.de
- Update to version 1.6.0
* Wed Jan 25 2006 - mls@suse.de
- converted neededforbuild to BuildRequires
* Fri Jan 20 2006 - mrueckert@suse.de
- Initial Package of version 1.1.1
