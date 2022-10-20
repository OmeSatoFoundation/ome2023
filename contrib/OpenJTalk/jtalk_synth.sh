#!/bin/bash
set -eu
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

usage_exit() {
	echo "Usage: $0 [-o outputpath] [-m vocal] -w <speaking phrase>"
	echo "       echo <speaking phrase> | $0 -i [-m vocal]"
  echo ""
  echo "Without -o, the synthesis result is /tmp/jsay.wav"
	exit 1
}

OUTPUTPATH=
SPEAKING=
VOCAL=
I_FLAG=
W_FLAG=
O_FLAG=

while getopts :m:o:w:i OPT
do
  case $OPT in
    i) I_FLAG=1
      SPEAKING=$(cat -)
      ;;
    w) W_FLAG=1
      SPEAKING=$OPTARG
      ;;
    m) VOCAL=$OPTARG
      ;;
    o) O_FLAG=1
      OUTPUTPATH=$OPTARG
      ;;
    \?) usage_exit
      ;;
  esac
done

if [ -z "$I_FLAG" ] && [ -z  "$W_FLAG" ]; then
	usage_exit
fi

if [ -z "$VOCAL" ]; then
	VOCAL=/usr/share/hts-voice/nitech-jp-atr503-m001/nitech_jp_atr503_m001.htsvoice
fi

if [ -z "$SPEAKING" ]; then
	SPEEAKING=$(cat -)
fi

if [ -z "$OUTPUTPATH" ]; then
  OUTPUTPATH=/tmp/jsay.wav
fi


echo "$SPEAKING" | open_jtalk \
-m $VOCAL \
-x /var/lib/mecab/dic/open-jtalk/naist-jdic \
-ow $OUTPUTPATH
