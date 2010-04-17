#!/bin/bash

source 'gisanfu-function.sh'

dirpoint=$1

if [ "$groupname" != "" ]; then
	if [ "$dirpoint" != "" ]; then
		result=`grep $dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`
		resultarray=(`grep $dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`)

		if [ "${#resultarray[@]}" -gt "1" ]; then
			run="dialog --menu 'Please Select DirPoint' 0 100 20 `grep $dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '` 2> /tmp/dirpoint.tmp"
			eval $run
			result=`cat /tmp/dirpoint.tmp`
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
		run="dialog --menu 'Please Select DirPoint' 0 100 20 `cat ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '` 2> /tmp/dirpoint.tmp"
		eval $run

		result=`cat /tmp/dirpoint.tmp`

		if [ "$result" == "" ]; then
			echo '[ERROR] dirpoint is empty'
		else
			dv $result
		fi
	fi
else
	echo '[ERROR] groupname is empty, please use GA command'
fi
