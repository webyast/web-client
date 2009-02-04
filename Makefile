all:
	rm -rf package; \
        find . -name "*.bak" -exec rm {} \; ;\
	mkdir package; \
	cp dist/* package; \
        cp -R webclient www; \
        find www -name "*.auto" -exec rm {} \;; \
        find www -name ".gitignore" -exec rm {} \;; \
        rm -f www/db/*.sqlite3; \
        rm -f www/log/development.log; \
	tar cvfj package/www.tar.bz2 www; \
        chmod 644 package/www.tar.bz2; \
        rm -rf www