
VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 0-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

PREFIX  ?= /usr

all:
	@echo "Haydenfetch doesn't need to be compiled, run 'make install' to install"

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/haydenfetch/haydens
	for hayden in haydens/*; do \
	install -m 0644 "$$hayden" $(DESTDIR)$(PREFIX)/share/haydenfetch/haydens/"$hayden"; \
	done
	install -m 0755 haydenfetch $(DESTDIR)$(PREFIX)/bin/haydenfetch
	@echo "You may need to install jq, jp2a, and neofetch"
	@echo "imagemagick is also required to use the kitty image backend"

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/haydenfetch
	rm -rf $(DESTDIR)$(PREFIX)/share/haydenfetch

control:
	cp control.template control
	sed -i 's/PACKAGE/haydenfetch/' control
	sed -i 's/ARCH/all/' control
	sed -i 's/VERSION/$(VERSION)/' control

debroot: control
	mkdir -p debroot/DEBIAN
	mkdir -p debroot/usr/bin
	mkdir -p debroot/usr/share/doc/haydenfetch
	cp -r haydens debroot/usr/share/haydenfetch
	cp control debroot/DEBIAN/control
	cp LICENSE debroot/usr/share/doc/haydenfetch/copyright
	cp haydenfetch debroot/usr/bin/haydenfetch
deb-pkg: options debroot
	dpkg-deb -b "debroot" "haydenfetch_$(VERSION)_all.deb"

clean:
	rm -rf debroot
	rm -f control
	rm -f haydenfetch_*_all.deb

.PHONY: all debroot control option install uninstall deb-pkg clean
