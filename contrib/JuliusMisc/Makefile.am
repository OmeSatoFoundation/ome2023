# yomi2voca.pl will be installed from the original Julius repository.
bin_SCRIPTS = convert_yomi.sh julius.sh julius_daemon.sh stopjulius.sh

bindatadir = $(bindir)
nobase_bindata_DATA = \
	julius_conf/default.jconf \
	julius_conf/model/lang_m/bccwj.60k.htkdic \
   	julius_conf/model/phone_m/jnas-tri-3k16-gid.binhmm \
   	julius_conf/model/phone_m/logicalTri

############################################################
# Install HSP header files to use Julius from HSP.
############################################################
hspcommondir = $(bindir)/common
hspcommon_DATA = julius.as julius_simple.as

############################################################
# Install default configuration, default startup scripts and
# tools for lecture students to use Julius in the simpler
# manner.
# TODO: parent makefile should succeed `dictdir` to this
# makefile.
############################################################
dictdir = $(datadir)/dict

built_scripts = julius.sh julius_daemon.sh
bin_SCRIPTS = convert_yomi.sh stopjulius.sh $(built_scripts)
dict_DATA = julius_conf/default.jconf
CLEANFILES = $(built_scripts) $(dict_DATA)
%: %.template
	sed 's;{{DICTDATADIR}};$(dictdir);g' $< > $@

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.
