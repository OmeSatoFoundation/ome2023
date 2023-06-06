openhspdatadir = $(datarootdir)/OpenHSP

OPENHSPSRCDIR = OpenHSP

# All the targets or sources should be relative to `OpenHSP/`, the project root.
# Later rule will add prefix of `$(OPENHSPSRCDIR)/` or run `cd` before refer them.
OPENHSPTARGETS = hsp3dish hsp3cl hspcmp hsed ipaexg.ttf
OPENHSPMANUALTARGETS = doclib hsptv sample index.htm index_en.htm main.css single.css
OPENHSPHELPMES_SRC = hspsdk/hsphelp/helpmes.hsp
OPENHSPHELPMES_AX = $(OPENHSPHELPMES_SRC:.hsp=.ax)
OPENHSPHELPMESDATA = hsphelp hsphelp_en hsp3gp

# Build helpmes.hsp to enable `hsed` to run helpmes.ax.
# CAUTION: when cross-compiled, the binary format of `hspcmp` is that of the target.
# The host requires well-configured binfmt to run hetero-binary-format executable.
# TODO: consider which is better to compile `helpmes.hsp`, at `make` here or with
# chroot at `install.bash`.
$(OPENHSPSRCDIR)/$(OPENHSPHELPMES_AX): $(OPENHSPSRCDIR)/$(OPENHSPHELPMES_SRC) $(OPENHSPSRCDIR)/hspcmp
	$(OPENHSPSRCDIR)/hspcmp -i -u --syspath=$(OPENHSPSRCDIR) --compath=$(OPENHSPSRCDIR)/common/ -o$@ $<

# Call the original makefile recursively to build OpenHSP.
$(addprefix $(OPENHSPSRCDIR)/, $(OPENHSPTARGETS)):
	cd $(OPENHSPSRCDIR) && $(MAKE) PKG_CONFIG=$(PKG_CONFIG) CC=$(CC) CXX=$(CXX) $(AM_MAKEFLAGS) all

install-openhsp-helpmes: $(OPENHSPSRCDIR)/$(OPENHSPHELPMES_AX) $(addprefix $(OPENHSPSRCDIR)/, $(OPENHSPHELPMESDATA))
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	@cd $(OPENHSPSRCDIR) ;\
	echo $(INSTALL) -D -t "$(DESTDIR)$(bindir)" $(OPENHSPHELPMES_AX) ; $(INSTALL) -D -t "$(DESTDIR)$(bindir)" $(OPENHSPHELPMES_AX)
	@cd $(OPENHSPSRCDIR) ;\
	list=$$(find $(OPENHSPHELPMESDATA) -type f) ;\
	for file in $$list; do echo $(INSTALL) -D "$$file" "$(DESTDIR)$(bindir)/$$file";\
	$(INSTALL) -D "$$file" "$(DESTDIR)$(bindir)/$$file"; done


install-openhsp-manual: $(shell find $(addprefix $(OPENHSPSRCDIR)/, $(OPENHSPMANUALTARGETS)) -type f)
	cd $(OPENHSPSRCDIR); \
	find $(OPENHSPMANUALTARGETS) -type f -exec $(INSTALL_DATA) -D "{}" "$(DESTDIR)$(openhspdatadir)/{}" \;

# automake default targets below;
# following targets are automatically called by functionalities of automake.

all-local: $(addprefix $(OPENHSPSRCDIR)/, $(OPENHSPTARGETS)) $(OPENHSPSRCDIR)/$(OPENHSPHELPMES_AX)

clean-local:
	cd $(OPENHSPSRCDIR) && $(MAKE) $(AM_MAKEFLAGS) clean

install-exec-local: install-openhsp-helpmes install-openhsp-manual
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

install-data-hook:
	cd "$(DESTDIR)$(bindir)" && \
	$(LN_S) "$(DESTDIR)$(openhspdatadir)/hsptv" .

uninstall-local:
	@list='$(OPENHSPTARGETS)'; \
	for file in $$list; do echo "rm -rf $(DESTDIR)$(bindir)/$$file"; rm -rf "$(DESTDIR)$(bindir)/$$file" || /bin/true; done
	@echo rm -rf '$(PIXMAPS_INSTALL)/hsed.png'; rm -rf "$(PIXMAPS_INSTALL)/hsed.png" || /bin/true
	@echo rm -rf '$(APPLICATIONS_INSTALL)/hsed.desktop'; rm -rf "$(APPLICATIONS_INSTALL)/hsed.desktop" || /bin/true
	@echo rm -rf '$(DESTDIR)$(bindir)/common'; rm -rf '$(DESTDIR)$(bindir)/common' || /bin/true
	@echo rm -rf '$(DESTDIR)$(bindir)/$(notdir $(OPENHSPHELPMES_AX))'; rm -rf "$(DESTDIR)$(bindir)/$(notdir $(OPENHSPHELPMES_AX))" || /bin/true
	@cd $(OPENHSPSRCDIR); \
	list=$$(find $(OPENHSPMANUALTARGETS) -type f); \
	for file in $$list; do echo "rm -rf $(DESTDIR)$(openhspdatadir)/$$file"; rm -rf $(DESTDIR)$(openhspdatadir)/$$file || /bin/true; done
