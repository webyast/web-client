all:
	(cd src; rake )

install:
	mkdir -p ../webclient/vendor/plugins; \
	( cd ../webclient/vendor/plugins; ln -s ../../../language-plugin/src/ language ); \

distclean: 
	rm -rf package; \
	rm src/src; \
	find . -name "*.bak" -exec rm {} \; ;\

dist: distclean
	mkdir package; \
	cp yast2-webclient-language.* package; \
        cp -R src www; \
        find www -name "*.auto" -exec rm {} \;; \
        find www -name ".gitignore" -exec rm {} \;; \
	tar cvfj package/www.tar.bz2 www; \
        chmod 644 package/www.tar.bz2; \
        rm -rf www