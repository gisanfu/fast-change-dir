#!/bin/bash

source 'gisanfu-function.sh'

dirpoint=$1

if [ "$dirpoint" != "" ]; then
	if [ "$groupname" != "" ]; then
		result=`grep $dirpoint ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`
		if [ "$result" != "" ]; then
			cd $result
			# check file count and ls action
			func_checkfilecount
		else
			echo '[ERROR] dirpoint is not exist!!'
		fi
	fi
else
	run="dialog --menu "aaa" 0 100 30 `cat ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '` 2> /tmp/dirpoint.tmp"
	eval $run

	result=`cat /tmp/dirpoint.tmp`

	if [ "$result" == "" ]; then
		echo '[ERROR] dirpoint is empty'
	else
		dv $result
	fi

	#cat ~/gisanfu-dirpoint-$groupname.txt | tr "\n" " " | tr ',' ' '
fi
