PKG_VERSION=16.4
PKG_RELEASE=1

VERSION=$(PKG_VERSION)-$(PKG_RELEASE)
SRPM=nzbget-$(VERSION).el7.centos.src.rpm
RELEASE_TAG=v$(VERSION)

PWD=$(shell pwd)
SPECDIR=$(PWD)/SPECS
BUILDDIR=$(PWD)/BUILD
BUILDROOTDIR=$(PWD)/BUILDROOT
RPMDIR=$(PWD)/RPMS
SOURCEDIR=$(PWD)/SOURCES
SRPMDIR=$(PWD)/SRPMS
SPEC=$(SPECDIR)/nzbget.spec

RPM_DEFINES=\
	--define "_pkg_version $(PKG_VERSION)" \
	--define "_pkg_release $(PKG_RELEASE)" \
	--define "_sourcedir $(SOURCEDIR)" \
	--define "_specdir $(SPECDIR)" \
	--define "_builddir $(BUILDDIR)" \
	--define "_srcrpmdir $(SRPMDIR)" \
	--define "_rpmdir $(RPMDIR)" \
	--define "_buildrootdir $(BUILDROOTDIR)"

DEFAULT_GOAL:=srpm

.PHONY: sources
sources:
	@mkdir -p $(BUILDDIR) $(BUILDROOTDIR) $(RPMDIR) $(SOURCEDIR) $(SRPMDIR)
	spectool --get-files --all --dir $(SOURCEDIR) $(RPM_DEFINES) $(SPEC)

.PHONY: srpm
srpm: sources
	rpmbuild --clean -bs $(RPM_DEFINES) $(SPEC)	

.PHONY: rpm
rpm: sources
	rpmbuild --clean -ba $(RPM_DEFINES) $(SPEC)	

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
		--file $(SRPMDIR)/$(SRPM)

.PHONY: release-build
release-build:
	copr-cli build cosmopetrich/nzbget "https://github.com/cosmopetrich/nzbget-rpms/releases/download/$(RELEASE_TAG)/$(SRPM)"

.PHONY: clean
clean:
	git clean -Xfd
