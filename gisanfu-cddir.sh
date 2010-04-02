#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

nextRelativeItem=$1
secondCondition=$2

#searchCondition='ls -AF | grep "/$" | grep -ir ^$nextRelativeItem'

itemList=(`ls -AF | grep "/$" | grep -ir ^$nextRelativeItem`)

if [ "$secondCondition" != "" ]; then
	itemList2=(`ls -AF | grep "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
fi

. gisanfu-relative.sh

if [ "$relativeitem" != "" ]; then
	cd $relativeitem
	# check file count and ls action
	func_checkfilecount
fi

relativeitem=''
itemList=''
