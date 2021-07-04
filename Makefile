
SHELL   := /usr/bin/env bash
VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 1.2-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

DARWIN_TARGETS := darwin-amd64 darwin-arm64

PREFIX  ?= /usr/local

all:
	@echo "Haydenfetch doesn't need to be compiled, run 'make install' to install"

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/haydenfetch/haydens
	mkdir -p $(DESTDIR)$(PREFIX)/share/doc/haydenfetch
	install -m 0644 LICENSE $(DESTDIR)$(PREFIX)/share/doc/haydenfetch/copyright
	for hayden in haydens/*; do \
	install -m 0644 "$$hayden" $(DESTDIR)$(PREFIX)/share/haydenfetch/"$$hayden"; \
	done
	install -m 0755 haydenfetch $(DESTDIR)$(PREFIX)/bin/haydenfetch
	@echo "You may need to install jp2a and findutils"

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/haydenfetch
	+rm -rf $(DESTDIR)$(PREFIX)/share/haydenfetch

controls: allcontrol darwin-amd64control darwin-arm64control

debroots: alldebroot darwin-amd64debroot darwin-arm64debroot

allcontrol:
	cp control.template allcontrol
	sed -i 's/PACKAGE/haydenfetch/' allcontrol
	sed -i 's/VERSION/$(VERSION)/' allcontrol
	sed -i 's/ARCH/all/' allcontrol

darwin-amd64control:
	cp control.template darwin-amd64control
	sed -i 's/PACKAGE/haydenfetch/' darwin-amd64control
	sed -i 's/VERSION/$(VERSION)/' darwin-amd64control
	sed -i 's/ARCH/darwin-amd64/' darwin-amd64control

darwin-arm64control:
	cp control.template darwin-arm64control
	sed -i 's/PACKAGE/haydenfetch/' darwin-arm64control
	sed -i 's/VERSION/$(VERSION)/' darwin-arm64control
	sed -i 's/ARCH/darwin-arm64/' darwin-arm64control

alldebroot: allcontrol
	mkdir -p alldebroot/DEBIAN
	mkdir -p alldebroot/usr/bin
	mkdir -p alldebroot/usr/share/doc/haydenfetch
	mkdir -p alldebroot/usr/share/haydenfetch

	cp -r haydens alldebroot/usr/share/haydenfetch
	cp allcontrol alldebroot/DEBIAN/control
	cp LICENSE alldebroot/usr/share/doc/haydenfetch/copyright
	cp haydenfetch alldebroot/usr/bin/haydenfetch

darwin-debroots-structure:
	mkdir -p darwin-a{md,rm}64debroot/DEBIAN
	mkdir -p darwin-a{md,rm}64debroot/opt/procursus/bin
	mkdir -p darwin-a{md,rm}64debroot/opt/procursus/share/doc/haydenfetch
	mkdir -p darwin-a{md,rm}64debroot/opt/procursus/share/haydenfetch

	echo darwin-a{md,rm}64debroot/opt/procursus/share/haydenfetch | xargs -n 1 cp -r haydens
	echo darwin-a{md,rm}64debroot/opt/procursus/share/doc/haydenfetch/copyright | xargs -n 1 cp LICENSE
	echo darwin-a{md,rm}64debroot/opt/procursus/bin/haydenfetch | xargs -n 1 cp haydenfetch

darwin-amd64debroot: darwin-amd64control darwin-debroots-structure
	cp darwin-amd64control darwin-amd64debroot/DEBIAN/control

darwin-arm64debroot: darwin-arm64control darwin-debroots-structure
	cp darwin-arm64control darwin-arm64debroot/DEBIAN/control

alldeb: alldebroot
	fakeroot dpkg-deb -b "alldebroot" "haydenfetch_$(VERSION)_all.deb"

darwin-amd64deb: darwin-amd64debroot
	fakeroot dpkg-deb -b "darwin-amd64debroot" "haydenfetch_$(VERSION)_darwin-amd64.deb"

darwin-arm64deb: darwin-arm64debroot
	fakeroot dpkg-deb -b "darwin-arm64debroot" "haydenfetch_$(VERSION)_darwin-arm64.deb"

deb-pkg: options alldeb darwin-amd64deb darwin-arm64deb

clean:
	rm -rf alldebroot darwin-amd64debroot darwin-arm64-debroot
	rm -f allcontrol darwin-amd64control darwin-arm64control
	rm -f haydenfetch_*_{all,darwin,a{md,rm}64}.deb

.PHONY: all controls debroots option install uninstall deb-pkg clean
