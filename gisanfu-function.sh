#!/bin/bash

# +--------+----------------------+
# |FUNCTION| func_statusbar       |
# +--------+----------------------+
# |ARGUMENT| $1: Action Name      |
# +--------+----------------------+
func_statusbar()
{
	echo "[ACT]=>$1"
	echo "[PWD]=>`pwd`"
}

# +--------+----------------------+
# |FUNCTION| func_checkfilecount  |
# +--------+----------------------+
# |ARGUMENT|                      |
# +--------+----------------------+
func_checkfilecount()
{
	filecount=`ls | wc -l`
	if [ "$filecount" == "0" ]; then
		echo "[EMPTY]"
	elif [ "$filecount" -le "6" ]; then
		ls -la
	else
		ls
	fi
}

func_dialog_menu()
{
	text=$1
	width=$2
	content=$3
	tmp=$4

	cmd="dialog --menu '$text' 0 $width 20 $content 2> $tmp"
	echo  $cmd

}
