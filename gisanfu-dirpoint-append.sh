#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

dirpoint=$1
nextRelativeItem=$2
secondCondition=$3

if [ "$dirpoint" != "" ]; then

	itemList=(`ls -AF | grep "/$" | grep -ir ^$nextRelativeItem`)
	
	# use (^) grep fast, if no match, then remove (^)
	if [ "${#itemList[@]}" -lt "1" ]; then
		itemList=(`ls -AF | grep "/$" | grep -ir $nextRelativeItem`)
		if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != "" ]]; then
			itemList2=(`ls -AF | grep "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi
	elif [ "${#itemList[@]}" -gt "1" ]; then
		if [ "$secondCondition" != "" ]; then
			itemList2=(`ls -AF | grep "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
		fi
	fi
	
	. gisanfu-relative.sh
	
	if [ "$relativeitem" != "" ]; then
		# $relativeitem
		# check file count and ls action
		func_checkfilecount
	fi
	
	if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
		echo "$dirpoint,`pwd`/$relativeitem" >> ~/gisanfu-dirpoint-$groupname.txt
		cat ~/gisanfu-dirpoint-$groupname.txt
	elif [ "$groupname" == "" ]; then
		echo '[ERROR] groupname is empty'
	fi
else
	echo '[ERROR] "dirpoint-arg01" "nextRelativeItem-arg01" "secondCondition"'
fi

relativeitem=''
itemList=''
