PWD=$(shell pwd)
SPEC=nzbget.spec

DEFAULT_GOAL:=srpm

.PHONY: srpm
srpm: 
	spectool --get-files --all nzbget.spec
	rpmbuild --define "_sourcedir $(PWD)" --define "_specdir $(PWD)" --define "_builddir $(PWD)" --define "_srcrpmdir $(PWD)" --define "_rpmdir $(PWD)" --define "_buildrootdir $(PWD)/build" --clean -bs $(SPEC)

.PHONY: clean
clean:
	rm -f nzbget-*.src.rpm nzbget-*.tar.gz
	rm -r build
