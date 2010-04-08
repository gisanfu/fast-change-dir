#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

nextRelativeItem=$1
secondCondition=$2

itemList=(`ls -AF --file-type | grep -v "/$" | grep -ir ^$nextRelativeItem`)

# use (^) grep fast, if no match, then remove (^)
if [ "${#itemList[@]}" -lt "1" ]; then
	itemList=(`ls -AF --file-type | grep -v "/$" | grep -ir $nextRelativeItem`)
	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != "" ]]; then
		itemList2=(`ls -AF --file-type | grep -v "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
	fi
elif [ "${#itemList[@]}" -gt "1" ]; then
	if [ "$secondCondition" != "" ]; then
		itemList2=(`ls -AF --file-type | grep -v "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
	fi
fi

. gisanfu-relative.sh

if [ "$relativeitem" != "" ]; then
	vim $relativeitem
fi

relativeitem=''
itemList=''
