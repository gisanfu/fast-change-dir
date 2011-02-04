#!/bin/bash

# 這支程式是設計給搜尋功能，用來append多個檔案所使用

files=($@)

if [ "$groupname" != '' ]; then
	for file in ${files[@]}
	do
		# 取得實際的路徑
		# 這裡可能有以下幾種狀況:
		# ../aaa.txt
		# ./aaa.txt
		# aaa.txt
		# /home/user/aaa.txt
		absoluteitem_path=`readlink -m $file`
		checkline=`grep "$absoluteitem_path" $fast_change_dir_config/vimlist-$groupname.txt | wc -l`
		if [ "$checkline" -lt 1 ]; then
			echo "\"$absoluteitem_path\"" >> $fast_change_dir_config/vimlist-$groupname.txt
		fi
	done

	# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
	echo '[WAIT] 預設是只暫存所選取的檔案 [N0,y1]'
	echo '[WAIT] 或是編輯列表 [j]'
	echo '[WAIT] 還是清空它 [k]'
	read -n 1 inputchar
	if [[ "$inputchar" == 'y' || "$inputchar" == "1" ]]; then
		# 取得最後append的檔案位置，這樣子vim -p以後就可以直接跳過該位置，就不用一直在gt..gt..gt..gt...
		checklinenumber=`cat $fast_change_dir_config/vimlist-$groupname.txt | nl -w1 -s: | grep "$absoluteitem_path" | head -n 1 | awk -F: '{print $1}'`
		cmd='vff "vim'

		# 不知道為什麼不能超過10，超過會出現以下的錯誤訊息
		# 太多 "+command" 、 "-c command" 或 "--cmd command" 參數
		# 查詢更多資訊請執行: "vim -h"
		if [ "$checklinenumber" -lt 10 ]; then
			for i in `seq 1 $checklinenumber`
			do
				cmd="$cmd +tabnext"
			done
		else
			echo '[NOTICE] 10以上的tabnext會有問題，所以我略過了:p'
		fi

		cmd="$cmd -p $fast_change_dir_config/vimlist-$groupname.txt\""
		eval $cmd
	elif [[ "$inputchar" == 'n' || "$inputchar" == "0" ]]; then
		echo "Your want append other file"
	elif [ "$inputchar" == 'j' ]; then
		vfff
	elif [ "$inputchar" == 'k' ]; then
		vffff
	else
		echo "Your want append other file"
	fi
else
	vim -p ${files[@]}
fi

# 結束前，把這裡所用到的變數給清空
files=''
file=''
inputvar=''
checkline=''
cmd=''
checklinenumber=''
