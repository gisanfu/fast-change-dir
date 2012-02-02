#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/dialog.sh"

if [ "$groupname" != "" ]; then

	cmdlist="cat $fast_change_dir_project_config/vimlist-$groupname.txt"

	# 這是多行文字檔內容，變成以空格分格成字串的步驟
	cmdlist2='| tr "\n" " "'
	cmdlist="$cmdlist $cmdlist2"
	cmdlist_result=`eval $cmdlist`
	cmd="d2 "

	# 檢查一下數量，如果是一筆的話，那就自動跳到那一筆
	# 這樣子只有一筆的時候，會比較方便
	# 會這樣子寫，是因為不要去影響其它程式的相依性
	count=`cat $fast_change_dir_project_config/vimlist-$groupname.txt | wc -l`

	#if [ "$count" == 1 ]; then
	#  cmd="$cmd +tabnext"
	#fi

	# 如果大於1筆，就用選擇的方式，選擇第一次要看到的檔案
	if [ "$count" -gt 1 ]; then
		vimlist_array=(`cat $fast_change_dir_project_config/vimlist-$groupname.txt`)
		tmpfile="$fast_change_dir_tmp/`whoami`-cddir2-ui-dialogselect-$( date +%Y%m%d-%H%M ).txt"
		dialogitems=''
		start=1
		for echothem in ${vimlist_array[@]}
		do
			dialogitems=" $dialogitems '$start' $echothem "
			start=$(expr $start + 1)
		done
		cmd2=$( func_dialog_menu '選擇一個檔案位置進入該資料夾 ' 100 "$dialogitems" $tmpfile )

		eval $cmd2
		result=`cat $tmpfile`
		echo $result

		if [ -f "$tmpfile" ]; then
			rm -rf $tmpfile
		fi

		if [ "$result" != "" ]; then
			if [ "$result" -lt 10 ]; then
				# 為了加快速度而這麼寫的
				#tabennn=('' '+tabnext' '+tabnext +tabnext' '+tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext')
				#cmd="$cmd ${tabennn[$result]}"
				#echo ${vimlist_array[$(expr $result + 1)]}
				cmd="$cmd ${vimlist_array[$(expr $result - 1)]}"
			else
				echo '[NOTICE] 10以上的tabnext會有問題，所以我略過了:p'
			fi
		else
			# 如果使用者選擇取消，那就取消整個vff
			cmd=""
		fi
	fi

	if [ "$cmd" != '' ]; then
		echo $cmd
		eval $cmd
	fi
	func_checkfilecount
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi

unset vimlist_array
unset cmd
