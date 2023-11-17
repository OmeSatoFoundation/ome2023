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

bin_SCRIPTS = convert_yomi.sh julius.sh julius_daemon.sh stopjulius.sh
dict_DATA = julius_conf/default.jconf
CLEANFILES = $(bin_SCRIPTS) $(dict_DATA)
%: %.template
	sed 's;{{DICTDATADIR}};$(dictdir);g' $< > $@

#TODO: hspcommondir should be at /usr/share/hsp but edit on hsed required to do so.
