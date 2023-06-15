bin_SCRIPTS = oled rpz-sensor spi FaBoOLED_EROLED096
# TODO: FaBoOLED_EROLED096 should be on /usr/lib/python3.x/site-packages.

hspcommondir = $(bindir)/common
hspcommon_DATA = rpz-fabo.as rpz-gpio.as rpz-gpio-cl.as

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.

install-data-hook:
	sed -i 's;/home/pi/ome/bin/common;$(hspcommondir);g' $(addprefix $(DESTDIR)$(hspcommondir)/, $(hspcommon_DATA))
	sed -i 's;/home/pi/ome/bin;$(bindir);g' $(addprefix $(DESTDIR)$(bindir)/, $(bin_SCRIPTS))
