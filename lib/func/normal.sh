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
	if [ "$fast_change_dir_auto_list_file_enable" == '1' ]; then
		echo "[PWD]=>`pwd`"
		filecount=`ls | wc -l`
		if [ "$filecount" == "0" ]; then
			echo "[EMPTY]"
		elif [ "$filecount" -le "6" ]; then
			ls -la
		else
			ls
		fi
	fi
}
