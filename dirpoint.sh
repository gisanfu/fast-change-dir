#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/dialog.sh"

# default ifs value
default_ifs=$' \t\n'

# fix space to effect array result
IFS=$'\012'

dirpoint=$1
tmpfile="$fast_change_dir_tmp/`whoami`-dirpoint-dialog-$( date +%Y%m%d-%H%M ).txt"

if [ "$groupname" != "" ]; then

	if [ ! -f $fast_change_dir_project_config/dirpoint-$groupname.txt ]; then
		touch $fast_change_dir_project_config/dirpoint-$groupname.txt
	fi

	if [ "$dirpoint" != "" ]; then
		result=`grep ^$dirpoint[[:alnum:]]*, $fast_change_dir_project_config/dirpoint-$groupname.txt | cut -d, -f2`
		resultarray=(`grep ^$dirpoint[[:alnum:]]*, $fast_change_dir_project_config/dirpoint-$groupname.txt | cut -d, -f2`)

		if [ "${#resultarray[@]}" -gt "1" ]; then
			cmd=$( func_dialog_menu 'Please Select DirPoint' 100 `grep $dirpoint[[:alnum:]]*, $fast_change_dir_project_config/dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '`  $tmpfile )

			eval $cmd
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi

			if [ "$result" == "" ]; then
				echo '[ERROR] dirpoint is empty'
			else
				dv $result
			fi
		elif [ "${#resultarray[@]}" == "1" ]; then
			cmd="cd $result"
			eval $cmd
			func_checkfilecount
		else
			echo '[ERROR] dirpoint is not exist!!'
		fi
	else
		resultvalue=`cat $fast_change_dir_project_config/dirpoint-$groupname.txt | wc -l`

		if [ "$resultvalue" -ge "1" ]; then
			echo ${#resultarray[@]}
			cmd=$( func_dialog_menu 'Please Select DirPoint' 100 `cat $fast_change_dir_project_config/dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '` $tmpfile )
			eval $cmd
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi

			if [ "$result" == "" ]; then
				echo '[ERROR] dirpoint is empty'
			else
				dv $result
			fi
		else
			echo '[ERROR] Please use DVV cmd to create dirpoint'
		fi

	fi
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi

tmpfile=''
IFS=$default_ifs
