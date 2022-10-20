#module
    #deffunc init_julius str dicpath
      await 1
      exec "killall -s9 julius"
      exec "julius_daemon.sh \"" + dicpath + "\" "
      sdim buf, 4096
      wait 1000
      return

    #defcfunc is_recieved int _socidx
        BEGIN_RECOGOUT = "<RECOGOUT>"
        END_RECOGOUT   = "</RECOGOUT>"
        socidx = _socidx
        sdim tmpbuf, 4096
        repeat
          sockgetm tmpbuf, 1, socidx, 64
          if stat == 0 {
            buf += tmpbuf
          } else : if stat != 11 {
            mes "Error while reading socket: stat = " + stat
            end
          }else {
            break
          }
        loop
        p1 = instr(buf, 0, BEGIN_RECOGOUT)
        p2 = instr(buf, p1, END_RECOGOUT)
        if p1 != -1 && p2 != -1{
          return 0
        }
        return -1

    #deffunc get_word_list array words, array cm
        W_PREFIX = "WORD=\""
        W_POSTFIX = "\""
        CM_PREFIX = "CM=\""
        CM_POSTFIX = "\""
        W_PREFIX_LEN = 6
        W_POSTFIX_LEN = 1
        CM_PREFIX_LEN = 4
        CM_POSTFIX_LEN = 1
        flg = 1
        idx = 0
        pidx = 0
        ;while flg
        repeat
          p1 = instr(buf, pidx, W_PREFIX)
          if p1 == -1 : break
          p1 = p1 + pidx
          p2 = instr(buf, p1+W_PREFIX_LEN, W_POSTFIX)
          if p2 == -1 : break
          word = strmid(buf, p1+W_PREFIX_LEN, p2)
          words(idx) = word

          pidx = p1+W_PREFIX_LEN+p2+W_POSTFIX_LEN

          c1 = instr(buf, pidx, CM_PREFIX)
          if c1 == -1 : break
          c1 = c1 + pidx
          c2 = instr(buf, c1+CM_PREFIX_LEN, CM_POSTFIX)
          if c2 == -1 : break
          cmprob = strmid(buf, c1+CM_PREFIX_LEN, c2)
          cm(idx) = double(cmprob)

          idx = idx+1
          pidx = p1+W_PREFIX_LEN+p2+W_POSTFIX_LEN
        loop
        buf = ""
        return
#global
