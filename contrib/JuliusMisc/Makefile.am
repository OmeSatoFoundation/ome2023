bin_SCRIPTS = convert_yomi.sh julius.sh julius_daemon.sh stopjulius.sh

bindatadir = $(bindir)
nobase_bindata_DATA = \
	julius_conf/default.jconf \
	julius_conf/model/lang_m/bccwj.60k.htkdic \
   	julius_conf/model/phone_m/jnas-tri-3k16-gid.binhmm \
   	julius_conf/model/phone_m/logicalTri

hspcommondir = $(bindir)/common
hspcommon_DATA = julius.as julius_simple.as

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.
