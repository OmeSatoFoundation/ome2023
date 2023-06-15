bin_SCRIPTS = jtalk.sh jtalk_synth.sh

jtalkdir = $(datadir)/jtalk
jtalk_DATA = \
voices/htsvoice-tohoku-f01/tohoku-f01-angry.htsvoice \
voices/htsvoice-tohoku-f01/tohoku-f01-happy.htsvoice \
voices/htsvoice-tohoku-f01/tohoku-f01-neutral.htsvoice \
voices/htsvoice-tohoku-f01/tohoku-f01-sad.htsvoice



hspcommondir = $(bindir)/common
hspcommon_DATA = jtalk.as

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.

install-data-hook:
	sed -i 's;/home/pi/ome/bin/common;$(hspcommondir);g' $(addprefix $(DESTDIR)$(hspcommondir)/, $(hspcommon_DATA))
	sed -i 's;/home/pi/ome/bin;$(bindir);g' $(addprefix $(DESTDIR)$(bindir)/, $(bin_SCRIPTS))
