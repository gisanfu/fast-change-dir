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


cd $1
func_statusbar 'GOTO-PARENT-DIR'
# check file count and ls action
func_checkfilecount

