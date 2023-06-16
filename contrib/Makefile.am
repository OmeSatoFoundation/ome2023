JULIUS_DIR = Julius
SUBDIRS = Dictationkit HTMLParse OpenHSP OpenHSPUtil FaBo JuliusMisc IR OpenJTalk WebServer

all-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) all
check-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) check
clean-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) clean
distclean-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) distclean

install-exec-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) install
install-data-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) install
uninstall-local:
	cd $(JULIUS_DIR) && $(MAKE) prefix=$(DESTDIR)$(prefix) $(AM_MAKEFLAGS) uninstall
