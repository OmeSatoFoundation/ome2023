;	curl and easy xml parse module
#ifndef __hspcurl__
#define __hspcurl__
#include "cmdexec.as"
#module

#deffunc curl str _p1, var _p2
	;	curl呼び出し
	;	curl "URL", "buffer name"
    creattmp tmpfile
	exec "curl \""+_p1+"\" -o "+tmpfile
    notesel _p2
    noteload tmpfile
    deltmp tmpfile
	return 0

#deffunc xmltag str _p1, str _p2, int _p3

	;	特定のXMLタグを集める
	;	xmltag "XMLファイル名","タグ名",個数(0=max)
	;	( 例: xmltag "data.xml","title" )
	;	結果は変数bufに返ります、「xmlresult 変数」で取得できます
	;
	sdim buf@,$10000
	sdim xml,$10000
	sdim s1,256
	notesel xml
	noteload _p1

	i=0
	max=_p3
	if max<=0 : max=100
	tagstr="<"+_p2+">"
	tagstr2="</"+_p2+">"
	repeat max
		res=instr(xml,i,tagstr)
		res2=instr(xml,i,tagstr2)
		if((res<0)||(res2<0)) : break
		res+=strlen(tagstr)
		len=res2-res
		s1=strmid(xml,i+res,len)
		i+=res2+strlen(tagstr2)
		;mes "i="+i+"res"+res+"/"+res2+"\r"
		;mes s1+"\r"
		buf@+=s1+"\n"
	loop
	return 0

#deffunc xmlresult var _p1

	;	xmltagの結果を変数に取得する
	;	xmlresult 変数
	;
	_p1=buf@
	return

#deffunc xmlload str _p1

	;	xmlファイルを読み込む
	;	xmlload "XMLファイル名"
	;
	sdim buf@,$10000
	notesel buf@
	noteload _p1
	return

#deffunc xmltable str _p1, str _p2

	;	特定のXMLタグを集める
	;	xmltag "XMLファイル名","タグ名",個数(0=max)
	;	( 例: xmltag "data.xml","title" )
	;	結果は変数bufに返ります、「xmlresult 変数」で取得できます
	;
	sdim buf@,$10000
	sdim xml,$10000
	sdim tbl,$1000
	sdim s1,256
	notesel xml
	noteload _p1
	tagstr="<table"
	tagstr2="</table>"
	tagstr3="id=\""+_p2+"\""
	i=0
	j=-1
	repeat
		res=instr(xml,i,tagstr)
		res2=instr(xml,i,tagstr2)
		if ((res<0)||(res2<0)) : break
		res+=strlen(tagstr)
		len=res2-res
		tbl=strmid(xml,i+res,len)
		i+=res2+strlen(tagstr2)
		res3=instr(tbl,0,tagstr3)
		if res3>=0 {
			gosub *tbl_split
		}
	loop
	return

*tbl_split
	;	tableのtd,trを分解する
	idx=0
	max=strlen(tbl)
	s1=""
*tbl_search
	if idx>=max : goto *tbl_done
	;
	a1=peek(tbl,idx)
	if a1!='<' : goto *tbl_next
	;
	idx++
	a1=peek(tbl,idx)
	idx++
	if a1=='/' : goto *tbl_endtag
	;
	a2=peek(tbl,idx)
	idx++
	tagflag=0
	if ((a1='t')&&(a2='r')) : tagflag=1
	if ((a1='T')&&(a2='R')) : tagflag=1
	if ((a1='t')&&(a2='d')) : tagflag=2
	if ((a1='T')&&(a2='D')) : tagflag=2

*tbl_next3
	; '>'まで進む
	if idx>=max : goto *tbl_done
	a1=peek(tbl,idx)
	if a1='>' : goto *tbl_next4
	idx++
	goto *tbl_next3
*tbl_next4
	idx++
	if tagflag=1 : s1="" : tdstart=-1
	if tagflag=2 : tdstart=idx
	goto *tbl_search

*tbl_endtag
	; 閉じるタグ
	a1=peek(tbl,idx):a2=peek(tbl,idx+1)
	idx+=2
	tagflag=0
	if ((a1='t')&&(a2='r')) : tagflag=1
	if ((a1='T')&&(a2='R')) : tagflag=1
	if ((a1='t')&&(a2='d')) : tagflag=2
	if ((a1='T')&&(a2='D')) : tagflag=2

	if tagflag=1 : buf@+=s1+"\n"
	if tagflag=2 {
		if tdstart>=0 {
			len=idx-tdstart-4
			s1+=strmid(tbl,tdstart,len)+","
			tdstart=-1
		}
	}

*tbl_next2
	; '>'まで進む
	if idx>=max : goto *tbl_done
	a1=peek(tbl,idx)
	if a1='>' : goto *tbl_next
	idx++
	goto *tbl_next2
*tbl_next
	idx++
	goto *tbl_search
*tbl_done
	;
	buf@+=s1+"\n"
	return


#global
#endif


