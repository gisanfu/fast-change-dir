#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/relativeitem.sh"

# cmd1、2是第一、二個關鍵字
cmd1=$1
cmd2=$2
# 位置，例如e就代表1，或者你也可以輸入1
cmd3=$3

# 是否要vff，如果沒有指定，就是會詢問使用者
# 不詢問，不要vff的話，就放0
# 不詢問，要vff的話，就放1
isVFF=$4

item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "file"` )

relativeitem=''
if [ "${#item_array[@]}" -gt 1 ]; then
	echo "重覆的檔案數量: 有${#item_array[@]}筆"
	number=1
	for bbb in ${item_array[@]}
	do
		echo "$number. $bbb"
		number=$((number + 1))
	done
elif [ "${#item_array[@]}" -eq 1 ]; then 
	relativeitem=${item_array[0]}
fi

if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
	if [ "$isVFF" == '0' ]; then
		inputchar='n'
	elif [ "$isVFF" == '1' ]; then
		inputchar='y'
	else
		isVFF=''
	fi

	# 這裡可以考慮在加上一項，就是不要append這一個檔案
	if [ "$isVFF" == '' ]; then
		# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
		echo '[WAIT] 預設是只暫存所選取的檔案 [N0,y1]'
		echo '[WAIT] 或是編輯列表 [j]'
		echo '[WAIT] 還是清空它 [k]'
		read -n 1 inputchar
	fi

	# 檢查一下，看文字檔裡面有沒有這個內容，如果有，當然就不需要在append
	selectitem=''
	selectitem=`pwd`/$relativeitem
	checkline=`grep "$selectitem" ~/gisanfu-vimlist-$groupname.txt | wc -l`
	if [ "$checkline" -lt 1 ]; then
		echo "\"$selectitem\"" >> ~/gisanfu-vimlist-$groupname.txt
	else
		echo '[NOTICE] File is exist'
	fi

	if [[ "$inputchar" == 'y' || "$inputchar" == "1" ]]; then
		# 取得最後append的檔案位置，這樣子vim -p以後就可以直接跳過該位置，就不用一直在gt..gt..gt..gt...
		checklinenumber=`cat ~/gisanfu-vimlist-$groupname.txt | nl -w1 -s: | grep "$selectitem" | head -n 1 | awk -F: '{print $1}'`
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

		cmd="$cmd -p ~/gisanfu-vimlist-$groupname.txt\""
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

	# 最後，顯示目前目錄的檔案
	func_checkfilecount

elif [ "$groupname" == "" ]; then
	echo '[ERROR] Argument or $groupname is empty'
fi

unset cmd
unset cmd1
unset cmd2
unset cmd3
unset number
unset item_array
unset checklinenumber
unset relativeitem
unset selectitem
