#ifndef HTMLPARSER_AS
#define HTMLPARSER_AS
#include "cmdexec.as"
#module
#deffunc splitnl var html, var v
	sdim _lf
	poke _lf, , 10
	strrep html, "\n", _lf
	strrep html, "\r", _lf
	split html, _lf, v
	return
#deffunc htmltag str html, str tag, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmltag --filename=" + _t + " --tag=" + tag, v
	deltmp _t
	return
#deffunc htmltagattr str html, str tag, str attrs, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmltagattr --filename=" + _t + " --tag=" + tag + " --attr=" + attrs, v
	deltmp _t
	return
#deffunc htmltable str html, str attrs, var v
	htmltagattr html, "table", attrs, _x
	htmltag _x, "td", _x
	htmluntag _x, v
	return	
#deffunc htmlsrc str html, str tag, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmlsrc --filename" + _t + " --tag=" + tag, v
	deltmp _t
	return
#deffunc htmltext str html, str tag, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmltext --filename=" + _t + " --tag=" + tag, v
	deltmp _t
	return
#deffunc htmllink str html, str tag, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmllink --filename" + _t + " --tag=" + tag, v
	deltmp _t
	return
#deffunc htmlval str html, str tag, str attrs, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmlval --filename=" + _t + " --tag=" + tag + " --attr=" + attrs, v
	deltmp _t
	return
#deffunc htmltagn str html, str tag, int p, int n, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmltagn --filename=" + _t + " --tag=" + tag + " --pos=" + str(p) + " --number=" + str(n), v
	deltmp _t
	return
#deffunc htmluntag str html, var v
	creattmp _t
	notesel _buf
	noteadd html
	notesave _t
	memset _buf, '', notesize
	cmdexec "htmlparser --command=htmluntag --filename=" + _t, v
	deltmp _t
	return

#global
#endif
