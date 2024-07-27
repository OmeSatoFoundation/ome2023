GIT = @have_git@
dictdir = $(datadir)/dict
bindatadir=$(bindir)
DKITPATH = dictation-kit

bin_SCRIPTS = run-linux-gmm.sh

# TODO: 2023-11-16T18:42:00+09:00
# ensure these scripts are at the proper directory and
# theses scripts refers proper targets.
JCONF = am-gmm.jconf main.jconf
dict_DATA = $(JCONF)

############################################################
# Install phonetic models
############################################################
langmdatadir=$(dictdir)/model/lang_m
phonemdatadir=$(dictdir)/model/phone_m
# TODO: these file should be under $(datadir).
# Migration requires fix of hardcodings in JuliusMisc.
langmdata_DATA = \
	dictation-kit/model/lang_m/bccwj.60k.htkdic \
	dictation-kit/model/lang_m/bccwj.60k.bingram
phonemdata_DATA = \
	dictation-kit/model/phone_m/jnas-tri-3k16-gid.binhmm \
	dictation-kit/model/phone_m/logicalTri-3k16-gid.bin \
	dictation-kit/model/phone_m/logicalTri

CLEANFILES = $(bin_SCRIPTS) $(JCONF)

############################################################
# Custom rules
############################################################
$(DKITPATH):
	$(GIT) clone -n https://github.com/julius-speech/dictation-kit.git $(srcdir)/$(DKITPATH)
	cd $(srcdir)/$(DKITPATH) && git checkout 1ceb4dec245ef482918ca33c55c71d383dce145e

$(langmdata_DATA) $(phonemdata_DATA): $(DKITPATH)

%: %.template
	sed 's;{{DICTDATADIR}};$(dictdir);g' $< > $@

.PHONY: clean-local
clean-local:
	-rm -rf $(JCONF) $(DKITPATH) $(bin_SCRIPTS)
