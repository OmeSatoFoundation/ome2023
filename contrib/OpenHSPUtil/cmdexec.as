#ifndef CMDEXEC_AS
#define CMDEXEC_AS
#module
#deffunc creattmp var _tname
	_tmpdir = "/tmp/"
	_tmpname = "tmpname" + str(rnd(1000))
	exec "mktemp " + _tmpdir + "tmp.XXXXXX >"+_tmpdir + _tmpname
	notesel _tmp 
	noteload _tmpdir + _tmpname
	noteget _c
	_tname = _c
	exec "rm " + _tmpdir + _tmpname
	return
#deffunc cmdexec str _cmd, var _stdout
	_tmp = ""
	creattmp _tmp
	exec _cmd + ">" + _tmp
	notesel _o
	noteload _tmp 
	_stdout = _o
	deltmp _tmp
	return
#deffunc deltmp var _tname
	exec "rm " + _tname
	return 
#global
#endif
