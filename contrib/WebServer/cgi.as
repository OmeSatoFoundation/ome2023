#ifndef CGI_AS
#define CGI_AS
#include "cmdexec.as"
#module
qsize = 0
#deffunc getquerystr var querystr
    creattmp tmpfile
    exec "echo $QUERY_STRING > " + tmpfile
    cmdexec "decurl.py " + tmpfile, query
    querystr = query
    return 
#deffunc getqueryval str key, var val
    sdim keys, 128, 128
    sdim vals, 128, 128
    getquerystr querystr
    split querystr, "&", qstr
    found = 0
    repeat stat
        split qstr(cnt), "=", keys(cnt), vals(cnt)
        found = instr(keys(cnt), 0, key)
        if(found != -1) {
            found = cnt
            break
        }
    loop
    if(found >= 0) {
        val = vals(found)
    } else {
        val = ""
    }
    return
#global
#endif
