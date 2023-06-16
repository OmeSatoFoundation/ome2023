bin_SCRIPTS = jtalk.sh jtalk_synth.sh

hspcommondir = $(bindir)/common
hspcommon_DATA = jtalk.as

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.

install-data-hook:
	sed -i 's;/home/pi/ome/bin/common;$(hspcommondir);g' $(addprefix $(DESTDIR)$(bindir)/, $(bin_SCRIPTS)) $(addprefix $(DESTDIR)$(hspcommondir)/, $(hspcommon_DATA))
	sed -i 's;/home/pi/ome/bin;$(bindir);g' $(addprefix $(DESTDIR)$(bindir)/, $(bin_SCRIPTS)) $(addprefix $(DESTDIR)$(hspcommondir)/, $(hspcommon_DATA))
