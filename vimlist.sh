#!/bin/bash

source "$fast_change_dir/gisanfu-function.sh"

program=$1

if [ "$groupname" != "" ]; then
	if [ "$program" == "" ]; then
		program2="vim -p ~/gisanfu-vimlist-$groupname.txt"
	else
		program2=$program
	fi

	cmdlist="cat ~/gisanfu-vimlist-$groupname.txt"

	# 正規的外面要用雙引包起來
	regex="^vim"

	# 如果program這個變數是空白，就代表會使用vim-p的指令
	# 使用vim，當然不會去開一些binary的檔案
	if [[ "$program" == '' || "$program" =~ $regex ]]; then
		# 先把一些己知的東西先ignore掉，例如壓縮檔
		cmdlist="$cmdlist | grep -v .tar.gz | grep -v .zip"
		cmdlist="$cmdlist | xargs -n 1 $fast_change_dir/gisanfu-only-text-filecontent.sh"
	fi

	# 這是多行文字檔內容，變成以空格分格成字串的步驟
	cmdlist2='| tr "\n" " "'
	cmdlist="$cmdlist $cmdlist2"
	cmdlist_result=`eval $cmdlist`
	cmd="$program2 $cmdlist_result"

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
