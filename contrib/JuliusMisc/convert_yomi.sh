#!/bin/bash
set -eu
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

usage_exit() {
echo "Usage: $0 <filename>"
exit 1
}

if [ $# -ne 1 ]; then
	usage_exit
fi

SOURCE_FILE=$1

cat $SOURCE_FILE | ruby -0777 -ne 'print $_.chomp("")' | yomi2voca.pl
