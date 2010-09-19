#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

dirPosition=$1

if [ "$dirPosition" != "" ]; then
	dirList=(`ls -AFL | grep "/$"`)
	if [ "${#dirList[@]}" -lt 1 ]; then
		func_statusbar 'THERE-IS-NO-DIR'
	else	
		if [ "${dirList[$dirPosition - 1]}" == "" ]; then
			func_statusbar 'THIS-POSITION-IS-NO-DIR'
		else
			cd ${dirList[$dirPosition - 1]}
			# check file count and ls action
			func_checkfilecount
		fi
	fi
else
	func_statusbar 'PLEASE-INPUT-ARG01'
fi
