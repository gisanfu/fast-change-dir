#!/bin/bash

# 這個檔案，是要讓gisanfu-svn.sh所呼叫的
# 方便以vim編輯某個版本號裡面的檔案群

revision=$1
tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt

if [ "$revision" == "" ]; then
	revisioncmd='/usr/bin/dialog --inputbox "請輸入版本號，以下為範例=> 123:125(版本從123到125)、123:head(版本從123到最近)、123,125,129(不連續或者是連續且多筆的版本號)、127(等同於127:head)" 0 0'
	revisioncmd="$revisioncmd 2> $tmpfile"

	eval $revisioncmd
	revision=`cat $tmpfile`

	if [ "$revision" == "" ]; then
		echo '[ERROR] 使用者取消動作，或是沒有輸入版本號'
		exit
	fi
fi

items=(`svn log -v -r $revision | grep -e "^   M" -e "^   A" | sed  's/^   M \///g' | sed 's/^   A \///g'`)

for item in ${items[@]}
do
	if [ -f $item ]; then
		vimitems="$vimitems $item"
	fi
done

vim -p $vimitems
