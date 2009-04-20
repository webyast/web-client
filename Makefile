all:
	(cd webclient; rake db:migrate; rake makemo)

pot:
	(cd webclient; rake updatepo)

distclean: 
	rm po/yast_webclient.pot; \
	rm -rf package; \
        find . -name "*.bak" -exec rm {} \; ;\

dist: distclean
	mkdir package; \
	cp dist/* package; \
        cp -R webclient www; \
        find www -name "*.auto" -exec rm {} \;; \
        find www -name ".gitignore" -exec rm {} \;; \
        rm -f www/db/*.sqlite3; \
        rm -f www/log/development.log; \
        mkdir -p www/tmp/sockets; \
        mkdir -p www/tmp/sessions; \
        mkdir -p www/tmp/pids; \
        mkdir -p www/tmp/cache; \
        (for i in `ls www/vendor/plugins`; do if test -L www/vendor/plugins/$$i; then rm www/vendor/plugins/$$i; fi; done); \
	tar cvfj package/www.tar.bz2 www; \
        chmod 644 package/www.tar.bz2; \
        rm -rf www