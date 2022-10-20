#include "cmdexec.as"
#module
  voice_name = ""
  output_path = ""
  #deffunc jtload str sentence, int idx
    output_path = "/tmp/jsay.wav"
    await 1
    if voice_name = "" {
      exec "jtalk_synth.sh -o \"" + output_path + "\" -w \"" + sentence + "\""
    }else{
      exec "jtalk_synth.sh -o \"" + output_path + "\" -w \"" + sentence + "\" -m \"" + voice_name + "\""
    }
    mmload output_path, idx, 0
    return

  #deffunc setvoice str _voice_name
    voice_name = "/home/pi/ome/bin/openjtalk/voices/" + _voice_name
    return
  #deffunc jtsave str sentence, var file
    creattmp output_path
    await 1
    if voice_name = "" {
      exec "jtalk_synth.sh -o \"" + output_path + "\" -w \"" + sentence + "\""
    }else{
      exec "jtalk_synth.sh -o \"" + output_path + "\" -w \"" + sentence + "\" -m \"" + voice_name + "\""
    }
    ; ../tmp/tmp.??????
    ; CGI用
    file = "../" + output_path
    return 
#global
