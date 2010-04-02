#!/bin/bash

dirpoint=$1

if [ "$dirpoint" != "" ]; then
	if [ "$groupname" != "" ]; then
		result=`grep $dirpoint ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f2`
		if [ "$result" != "" ]; then
			cd $result
		else
			echo '[ERROR] dirpoint is not exist!!'
		fi
	fi
else
	echo '[ERROR] dirpoint is empty'
fi
