OPENHSPSRCDIR = OpenHSP
OPENHSPTARGETS = hsp3dish hsp3cl hspcmp hsed ipaexg.ttf

all-local:
	cd $(OPENHSPSRCDIR) && $(MAKE) PKG_CONFIG=$(PKG_CONFIG) CC=$(CC) CXX=$(CXX) $(AM_MAKEFLAGS) all

clean-local:
	cd $(OPENHSPSRCDIR) && $(MAKE) $(AM_MAKEFLAGS) clean

install-exec-local:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	@list='$(OPENHSPTARGETS)'; \
	for file in $$list; do \
	echo " $(INSTALL_PROGRAM) $(OPENHSPSRCDIR)/$$file '$(DESTDIR)$(bindir)'" ;\
	$(INSTALL_PROGRAM) $(OPENHSPSRCDIR)/$$file "$(DESTDIR)$(bindir)" || exit $$?; \
	done

APPLICATIONS=$(datarootdir)/applications
APPLICATIONS_INSTALL=$(DESTDIR)$(APPLICATIONS)
PIXMAPS=$(datarootdir)/pixmaps
PIXMAPS_INSTALL=$(DESTDIR)$(PIXMAPS)
install-data-local:
	$(INSTALL) -d $(APPLICATIONS_INSTALL)
	$(INSTALL) -d $(PIXMAPS_INSTALL)
	@echo " $(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.desktop '$(APPLICATIONS_INSTALL)'" ;\
	$(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.desktop "$(APPLICATIONS_INSTALL)"
	@echo " $(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.png '$(PIXMAPS_INSTALL)'" ;\
	$(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.png "$(PIXMAPS_INSTALL)"
	sed -i "s:/usr/share/pixmaps:$(PIXMAPS):g;s:/home/pi/OpenHSP:$(bindir):g" $(APPLICATIONS_INSTALL)/hsed.desktop
	sh -c 'cd $(OPENHSPSRCDIR) && find common -type f -exec $(INSTALL_DATA) -D "{}" "$(DESTDIR)$(bindir)/{}" \;'


uninstall-local:
	list='$(OPENHSPTARGETS)'; \
	@for file in $$list; do echo rm -rf $(DESTDIR)$(bindir)/$$file; rm -rf $(DESTDIR)$(bindir)/$$file || /bin/true; done
	@echo rm -rf '$(PIXMAPS_INSTALL)/hsed.png'; rm -rf "$(PIXMAPS_INSTALL)/hsed.png" || /bin/true
	@echo rm -rf '$(APPLICATIONS_INSTALL)/hsed.desktop'; rm -rf "$(APPLICATIONS_INSTALL)/hsed.desktop" || /bin/true
