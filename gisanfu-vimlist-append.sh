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

if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
	echo "`pwd`/$relativeitem" >> ~/gisanfu-vimlist-$groupname.txt
	cat ~/gisanfu-vimlist-$groupname.txt
	# 整個動作結束後，問使用者是否要針對這些append進來的東西做編輯

	tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt
	cmd=$( func_dialog_yesno 'Please Choose' 'Disable select Yes, Edit select NO' 70 "$tmpfile" )

	# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
	eval $cmd
	sel=$?
	case $sel in
		0) echo "Your want append other file";;
		1) /bin/gisanfu-vimlist.sh;;
		255) echo "Canceled by user by pressing [ESC] key";;
	esac

	# 最後，顯示目前目錄的檔案
	func_checkfilecount

elif [ "$groupname" == "" ]; then
	echo '[ERROR] groupname is empty'
fi

relativeitem=''
itemList=''
