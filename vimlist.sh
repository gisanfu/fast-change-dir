#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/dialog.sh"

program=$1

if [ "$groupname" != "" ]; then
	if [ "$program" == "" ]; then
		program2="vim -p $fast_change_dir_project_config/vimlist-$groupname.txt"
	else
		program2=$program
	fi

	cmdlist="cat $fast_change_dir_project_config/vimlist-$groupname.txt"

	# 正規的外面要用雙引包起來
	regex="^vim"

	# 如果program這個變數是空白，就代表會使用vim-p的指令
	# 使用vim，當然不會去開一些binary的檔案
	if [[ "$program" == '' || "$program" =~ $regex ]]; then
		# 先把一些己知的東西先ignore掉，例如壓縮檔
		cmdlist="$cmdlist | grep -v .tar.gz | grep -v .zip | grep -v .png | grep -v .gif | grep -v .jpeg | grep -v .jpg"
		cmdlist="$cmdlist | xargs -n 1 $fast_change_dir_bin/only-text-filecontent.sh"
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
		count=`cat $fast_change_dir_project_config/vimlist-$groupname.txt | wc -l`

		if [ "$count" == 1 ]; then
		  cmd="$cmd +tabnext"
		fi

		# 如果大於1筆，就用選擇的方式，選擇第一次要看到的檔案
		if [ "$count" -gt 1 ]; then
			vimlist_array=(`cat $fast_change_dir_project_config/vimlist-$groupname.txt`)
			tmpfile="$fast_change_dir_tmp/`whoami`-vimlist-dialogselect-$( date +%Y%m%d-%H%M ).txt"
			dialogitems=''
			start=1
			for echothem in ${vimlist_array[@]}
			do
				dialogitems=" $dialogitems '$start' $echothem "
				start=$(expr $start + 1)
			done
			cmd2=$( func_dialog_menu '你想從哪一個位置開始編輯 ' 100 "$dialogitems" $tmpfile )

			eval $cmd2
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi

			if [ "$result" != "" ]; then
				if [ "$result" -lt 10 ]; then
					# 為了加快速度而這麼寫的
					tabennn=('' '+tabnext' '+tabnext +tabnext' '+tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext')
					cmd="$cmd ${tabennn[$result]}"
				else
					echo '[NOTICE] 10以上的tabnext會有問題，所以我略過了:p'
				fi
			else
				# 如果使用者選擇取消，那就取消整個vff
				cmd=""
			fi
		fi
	fi

	if [ "$cmd" != '' ]; then
		eval $cmd
	fi
	func_checkfilecount
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi

unset vimlist_array
unset cmd
