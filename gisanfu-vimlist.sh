#!/bin/bash

source "$fast_change_dir/gisanfu-function.sh"

program=$1

if [ "$groupname" != "" ]; then
	if [ "$program" == "" ]; then
		program2="vim -p ~/gisanfu-vimlist-$groupname.txt"
	else
		program2=$program
	fi

	cmdlist=`cat ~/gisanfu-vimlist-$groupname.txt | tr "\n" " "`
	cmd="$program2 $cmdlist"

	# 檢查一下數量，如果是一筆的話，那就自動跳到那一筆
	# 這樣子只有一筆的時候，會比較方便
	# 會這樣子寫，是因為不要去影響其它程式的相依性
	if [ "$program" == "" ]; then
		count=`cat ~/gisanfu-vimlist-$groupname.txt | wc -l`
		if [ "$count" == '1' ]; then
		  cmd="$cmd +tabnext"
		fi
	fi

	eval $cmd
	func_checkfilecount
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi
