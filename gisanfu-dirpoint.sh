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
	echo '[ERROR] dirpoint is empty'
fi
