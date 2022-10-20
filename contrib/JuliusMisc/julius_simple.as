#module
#defcfunc detect_sound str _DICT
	THRESHOLD = 0.92
	OME_PATH = "/home/pi/ome"
	OME_PATH = "/home/pi/ome"
	JULIUS = OME_PATH + "/bin/julius"
	JCONF = OME_PATH + "/bin/record.jconf"
	DICT = _DICT
	res = ""
	exec "arecord -d 3 -f S16_LE -r 16000 ./tmp.wav"
	exec "echo ./tmp.wav > ./filelist.txt"
	exec JULIUS + " -C " + JCONF + " -w " + DICT + " -input rawfile -filelist ./filelist.txt -cutsilence > result.txt"
	notesel julius_result
	noteload "result.txt"
	word = get_detected(julius_result)
	cmscore = get_cmscore(julius_result)
	
	if cmscore >= THRESHOLD {
		res = word
	}
	return res
#global

#module
#defcfunc get_cmscore str _text
	text = _text
	cmscore = get_word(text, "cmscore1: ")
	return double(cmscore)
#global

#module
#defcfunc get_detected str _text
	text = _text
	detected = get_word(text, "sentence1: ")
	return detected
#global

#module
#defcfunc get_word str _text, str _sep
	sep = _sep
	text= _text
	idx_begin = instr(text, 0, sep)
	word = ""
	if idx_begin >= 0 {
		getstr word, text, idx_begin+strlen(sep), 0x0a
	}
	return word
#global
