#!/bin/bash

source 'gisanfu-function.sh'

# default ifs value
default_ifs=$' \t\n'

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
	# 檢查一下，看文字檔裡面有沒有這個內容，如果有，當然就不需要在append
	selectitem=''
	selectitem=`pwd`/$relativeitem
	checkline=`grep "$selectitem" ~/gisanfu-vimlist-$groupname.txt | wc -l`
	if [ "$checkline" -lt 1 ]; then
		echo "\"$selectitem\"" >> ~/gisanfu-vimlist-$groupname.txt
		cat ~/gisanfu-vimlist-$groupname.txt
	else
		echo '[NOTICE] File is exist'
	fi
	selectitem=''

	# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
	echo '[WAIT] 預設是只暫存所選取的檔案 [N0,y1]'
	echo '[WAIT] 或是編輯列表 [j]'
	echo '[WAIT] 還是清空它 [k]'
	read -n 1 inputchar
	if [[ "$inputchar" == 'y' || "$inputchar" == "1" ]]; then
		/bin/gisanfu-vimlist.sh
	elif [[ "$inputchar" == 'n' || "$inputchar" == "0" ]]; then
		echo "Your want append other file"
	elif [ "$inputchar" == 'j' ]; then
		vfff
	elif [ "$inputchar" == 'k' ]; then
		vffff
	else
		echo "Your want append other file"
	fi

	# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
	#tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt
	#cmd=$( func_dialog_yesno 'Please Choose' 'Disable select Yes, Edit select NO' 70 "$tmpfile" )
	#eval $cmd
	#sel=$?
	#case $sel in
	#	0) echo "Your want append other file";;
	#	1) /bin/gisanfu-vimlist.sh;;
	#	255) echo "Canceled by user by pressing [ESC] key";;
	#esac

	# 最後，顯示目前目錄的檔案
	func_checkfilecount

elif [ "$groupname" == "" ]; then
	echo '[ERROR] Argument or $groupname is empty'
fi

relativeitem=''
itemList=''
IFS=$default_ifs
