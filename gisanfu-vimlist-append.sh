#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

nextRelativeItem=$1
secondCondition=$2

itemList=(`ls -AF --file-type | grep -v "/$" | grep -ir ^$nextRelativeItem`)

if [ "$secondCondition" != "" ]; then
	itemList2=(`ls -AF --file-type | grep -v "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
fi

. gisanfu-relative.sh

if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
	echo "`pwd`/$relativeitem" >> ~/gisanfu-vimlist-$groupname.txt
	cat ~/gisanfu-vimlist-$groupname.txt
elif [ "$groupname" == "" ]; then
	echo '[ERROR] groupname is empty'
fi

relativeitem=''
itemList=''
