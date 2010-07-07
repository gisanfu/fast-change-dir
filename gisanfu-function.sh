#!/bin/bash

# +--------+----------------------+
# |FUNCTION| func_statusbar       |
# +--------+----------------------+
# |ARGUMENT| $1: Action Name      |
# +--------+----------------------+
func_statusbar()
{
	echo "[ACT]=>$1"
	#echo "[PWD]=>`pwd`"
}

# +--------+----------------------+
# |FUNCTION| func_checkfilecount  |
# +--------+----------------------+
# |ARGUMENT|                      |
# +--------+----------------------+
func_checkfilecount()
{
	echo "[PWD]=>`pwd`"
	filecount=`ls | wc -l`
	if [ "$filecount" == "0" ]; then
		echo "[EMPTY]"
	elif [ "$filecount" -le "6" ]; then
		ls -la
	else
		ls
	fi
}

# 這個是Dialog指令的選單功能
func_dialog_menu()
{
	text=$1
	width=$2
	content=$3
	tmp=$4

	cmd="dialog --menu '$text' 0 $width 20 $content 2> $tmp"
	echo $cmd
}

# 這個是Dialog指令的YesNo功能
func_dialog_yesno()
{
	title=$1
	text=$2
	width=$3

	cmd="dialog --title '$title' --yesno '$text' 7 $width"
	echo $cmd
}
