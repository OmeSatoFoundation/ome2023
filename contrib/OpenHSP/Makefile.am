OPENHSPSRCDIR = OpenHSP
OPENHSPTARGETS = hsp3dish hsp3cl hspcmp hsed
all-local:
	cd $(OPENHSPSRCDIR) && $(MAKE) $(AM_MAKEFLAGS) all

clean-local:
	cd $(OPENHSPSRCDIR) && $(MAKE) $(AM_MAKEFLAGS) clean

install-exec-local:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	@list='$(OPENHSPTARGETS)'; \
	for file in $$list; do \
	echo " $(INSTALL_PROGRAM) $(OPENHSPSRCDIR)/$$file '$(DESTDIR)$(bindir)'" ;\
	$(INSTALL_PROGRAM) $(OPENHSPSRCDIR)/$$file "$(DESTDIR)$(bindir)" || exit $$?; \
	done

APPLICATIONS=$(DESTDIR)$(datarootdir)/applications
PIXMAPS=$(DESTDIR)$(datarootdir)/pixmaps
install-data-local:
	$(INSTALL) -d $(APPLICATIONS)
	$(INSTALL) -d $(PIXMAPS)
	@echo " $(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.desktop '$(APPLICATIONS)'" ;\
	$(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.desktop "$(APPLICATIONS)"
	@echo " $(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.png '$(PIXMAPS)'" ;\
	$(INSTALL_DATA) $(OPENHSPSRCDIR)/hsed.png "$(PIXMAPS)"
	sed -i "s:/usr/share/pixmaps:$(PIXMAPS):g;s:/home/pi/OpenHSP:$(DESTDIR)$(bindir):g" $(APPLICATIONS)/hsed.desktop


uninstall-local:
	list='$(OPENHSPTARGETS)'; \
	@for file in $$list; do echo rm -rf $(DESTDIR)$(bindir)/$$file; rm -rf $(DESTDIR)$(bindir)/$$file || /bin/true; done
	@echo rm -rf '$(PIXMAPS)/hsed.png'; rm -rf "$(PIXMAPS)/hsed.png" || /bin/true
	@echo rm -rf '$(APPLICATIONS)/hsed.desktop'; rm -rf "$(APPLICATIONS)/hsed.desktop" || /bin/true
