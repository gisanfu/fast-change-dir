#!/bin/bash

source "$fast_change_dir/gisanfu-function.sh"

# default ifs value
default_ifs=$' \t\n'

# fix space to effect array result
IFS=$'\012'

nextRelativeItem=$1
secondCondition=$2

itemList=(`ls -AF .. | grep "/$" | grep -ir ^$nextRelativeItem`)

# use (^) grep fast, if no match, then remove (^)
if [ "${#itemList[@]}" -lt "1" ]; then
	itemList=(`ls -AF .. | grep "/$" | grep -ir $nextRelativeItem`)
	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != "" ]]; then
		itemList2=(`ls -AF .. | grep "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
	fi
elif [ "${#itemList[@]}" -gt "1" ]; then
	if [ "$secondCondition" != "" ]; then
		itemList2=(`ls -AF .. | grep "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
	fi
fi

. $fast_change_dir/gisanfu-relative.sh

if [ "$relativeitem" != "" ]; then
	cd ../$relativeitem
	# check file count and ls action
	func_checkfilecount
fi

relativeitem=''
itemList=''
IFS=$default_ifs
