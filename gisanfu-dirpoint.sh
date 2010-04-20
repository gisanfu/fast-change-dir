#!/bin/bash

source 'gisanfu-function.sh'

IFS=$'\012'

dirpoint=$1
tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt

if [ "$groupname" != "" ]; then

	if [ ! -f ~/gisanfu-dirpoint-$groupname.txt ]; then
		touch ~/gisanfu-dirpoint-$groupname.txt
	fi

	if [ "$dirpoint" != "" ]; then
		result=`grep ^$dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`
		resultarray=(`grep ^$dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`)

		if [ "${#resultarray[@]}" -gt "1" ]; then
			cmd=$( func_dialog_menu 'Please Select DirPoint' 100 `grep $dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '`  $tmpfile )

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
			cd $result
			func_checkfilecount
		else
			echo '[ERROR] dirpoint is not exist!!'
		fi
	else
		resultvalue=`cat ~/gisanfu-dirpoint-$groupname.txt | wc -l`

		if [ "$resultvalue" -ge "1" ]; then
			echo ${#resultarray[@]}
			cmd=$( func_dialog_menu 'Please Select DirPoint' 100 `cat ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '` $tmpfile )
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
