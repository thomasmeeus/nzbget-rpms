PKG_VERSION=16.4
PKG_RELEASE=1

VERSION=$(PKG_VERSION)-$(PKG_RELEASE)
SRPM=nzbget-$(VERSION).el7.centos.src.rpm
RELEASE_TAG=v$(VERSION)

PWD=$(shell pwd)
SPECDIR=$(PWD)/SPECS
SOURCES=$(PWD)/SOURCES
BUILDDIR=$(PWD)/.build
SPEC=$(SPECDIR)/nzbget.spec

RPM_DEFINES=\
	--define "_pkg_version $(PKG_VERSION)" \
	--define "_pkg_release $(PKG_RELEASE)" \
	--define "_sourcedir $(SOURCES)" \
	--define "_specdir $(SPECDIR)" \
	--define "_builddir $(PWD)" \
	--define "_srcrpmdir $(PWD)" \
	--define "_rpmdir $(PWD)" \
	--define "_buildrootdir $(BUILDDIR)"

DEFAULT_GOAL:=srpm

.PHONY: srpm
srpm: 
	spectool --get-files --all --dir $(SOURCES) $(RPM_DEFINES) $(SPEC)
	rpmbuild --clean -bs $(RPM_DEFINES) $(SPEC)	

.PHONY: release-tag
release-tag:
	git tag $(RELEASE_TAG)
	git push --tags


.PHONY: release-create
release-create:
	github-release release \
	    --user cosmopetrich \
	    --repo nzbget-rpms \
	    --tag $(RELEASE_TAG) \
	    --name "nzbget-$(VERSION)" \
	    --description "See https://copr.fedorainfracloud.org/coprs/cosmopetrich/nzbget/package/nzbget/ for binary packages." \


.PHONY: release-upload
release-upload:
	github-release upload \
		--user cosmopetrich \
		--repo nzbget-rpms \
		--tag $(RELEASE_TAG) \
		--name $(SRPM) \
		--file $(SRPM)

.PHONY:
release-build:
	copr-cli build cosmopetrich/nzbget "https://github.com/cosmopetrich/nzbget-rpms/releases/download/$(RELEASE_TAG)/$(SRPM)"

.PHONY: clean
clean:
	rm -f nzbget-*.src.rpm $(SOURCES)/nzbget-*-src.tar.gz
	rm -rf $(BUILDDIR)
