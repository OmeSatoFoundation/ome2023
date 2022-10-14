dictdir = $(datadir)/dict
dict_DATA = dictation-kit/model/phone_m/jnas-tri-3k16-gid.binhmm dictation-kit/model/phone_m/logicalTri-3k16-gid.bin am-gmm.jconf

$(dict_DATA):
	sed 's/{{DICTDATADIR}}/'"$(datadir)"'/g'
	git clone -n git@github.com:julius-speech/dictation-kit.git dictation-kit
	cd dictation-kit && git checkout 1ceb4dec245ef482918ca33c55c71d383dce145e
