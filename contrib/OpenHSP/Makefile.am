SRCDIR = OpenHSP
TARGETS = hsp3dish hsp3cl hspcmp hsed
DEST = /usr/local/bin
all-local:
	cd $(SRCDIR) && $(MAKE) -f makefile.raspbian $(AM_MAKEFLAGS) all

clean-local:
	cd $(SRCDIR) && $(MAKE) -f makefile.raspbian $(AM_MAKEFLAGS) clean

install-exec-local:
	$(INSTALL) -d $(DEST)
	list='$(TARGETS)'; \
	@for file in $$list; do \
	echo " $(INSTALL_PROGRAM) $(SRCDIR)/$$file '$(DEST)'" \
	$(INSTALL_PROGRAM) $(SRCDIR)/$$file "$(DEST)" || exit $$?; \
	done

uninstall-local:
	list='$(TARGETS)'; \
	@for file in $$list; do rm -rf $(DEST)/$$file; done
