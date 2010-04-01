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

if [ "$relativeitem" != "" ]; then
	echo "`pwd`/$1" >> ~/vimargumentlist.txt
	cat ~/vimargumentlist.txt
fi

relativeitem=''
itemList=''
