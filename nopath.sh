#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/dialog.sh"

# default ifs value
default_ifs=$' \t\n'

# fix space to effect array result
IFS=$'\012'

nopath=$1
tmpfile="$fast_change_dir_tmp/`whoami`-nopath-dialog-$( date +%Y%m%d-%H%M ).txt"

if [ ! -f $fast_change_dir_config/nopath.txt ]; then
	touch $fast_change_dir_config/nopath.txt
fi

if [ "$nopath" != "" ]; then
	result=`grep ^$nopath[[:alnum:]]*, $fast_change_dir_config/nopath.txt | cut -d, -f2`
	resultarray=(`grep ^$nopath[[:alnum:]]*, $fast_change_dir_config/nopath.txt | cut -d, -f2`)

	if [ "${#resultarray[@]}" -gt "1" ]; then
		cmd=$( func_dialog_menu 'Please Select nopath' 100 `grep $nopath[[:alnum:]]*, $fast_change_dir_config/nopath.txt | tr "\n" " " | tr ',' ' '`  $tmpfile )

		eval $cmd
		result=`cat $tmpfile`

		if [ -f "$tmpfile" ]; then
			rm -rf $tmpfile
		fi

		if [ "$result" == "" ]; then
			echo '[ERROR] nopath is empty'
		else
			wv $result
		fi
	elif [ "${#resultarray[@]}" == "1" ]; then
		cmd="cd $result"
		eval $cmd
		func_checkfilecount
	else
		echo '[ERROR] nopath is not exist!!'
	fi
else
	resultvalue=`cat $fast_change_dir_config/nopath.txt | wc -l`

	if [ "$resultvalue" -ge "1" ]; then
		echo ${#resultarray[@]}
		cmd=$( func_dialog_menu 'Please Select nopath' 100 `cat $fast_change_dir_config/nopath.txt | tr "\n" " " | tr ',' ' '` $tmpfile )
		eval $cmd
		result=`cat $tmpfile`

		if [ -f "$tmpfile" ]; then
			rm -rf $tmpfile
		fi

		if [ "$result" == "" ]; then
			echo '[ERROR] nopath is empty'
		else
			wv $result
		fi
	else
		echo '[ERROR] Please modify nopath file in your text config file'
	fi

fi

tmpfile=''
IFS=$default_ifs
