#! /bin/sh
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

usage_exit() {
echo "Usage: $0 <dictionary file name>"
exit 1
}

if [ $# -ne 1 ]; then
	usage_exit
fi

DIC_FILE=$1

julius -w $DIC_FILE -quiet -C $SCRIPT_DIR/julius_conf/default.jconf
