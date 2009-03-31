#
# Makefile for ruby-gettext
#

all:
	(ruby -rvendor-specific setup.rb config; ruby -rvendor-specific setup.rb setup)

install: all
	(ruby -rvendor-specific setup.rb install)

distclean:
	rm -f *~
	rm -f src/*~
	rm -rf package/*bz2

dist: distclean
	(cd ..; tar -cj --exclude=ruby-gettext/package -f ruby-gettext/package/ruby-gettext-1.93.0.tar.bz2 ruby-gettext)
