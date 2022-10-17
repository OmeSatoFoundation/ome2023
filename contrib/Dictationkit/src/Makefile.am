GIT = @have_git@
dictdir = $(datadir)/dict
OBJDIR = obj
# temporary dictation kit path to be cloned
DKITPATH = dictation-kit
PHONEMODELS = $(DKITPATH)/model/phone_m/jnas-tri-3k16-gid.binhmm $(DKITPATH)/model/phone_m/logicalTri-3k16-gid.bin $(DKITPATH)/model/lang_m/bccwj.60k.bingram $(DKITPATH)/model/lang_m/bccwj.60k.htkdic
JCONF = am-gmm.jconf main.jconf
dict_DATA = $(PHONEMODELS) $(JCONF)
dist_SOURCE = am-gmm_template.jconf main_template.jconf
CLEANFILES = 

$(DKITPATH):
	$(GIT) clone -n https://github.com/julius-speech/dictation-kit.git $(srcdir)/$(DKITPATH)
	cd $(srcdir)/$(DKITPATH) && git checkout 1ceb4dec245ef482918ca33c55c71d383dce145e

$(PHONEMODELS): $(DKITPATH)

%.jconf : %_template.jconf
	sed 's;{{DICTDATADIR}};$(dictdir);g' $< > $@

.PHONY: clean-local
clean-local:
	-rm -rf $(OBJDIR) $(JCONF) $(DKITPATH)
