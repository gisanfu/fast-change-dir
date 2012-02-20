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
# 想要vff，然後又要多選的狀況，那就放2，也會自動做vff的動作
# 同2，但不要vff的狀況
isVFF=$4

if [ "$isVFF" == '' ]; then
	isVFF=1
fi

item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "file"` )

relativeitem=''

if [ ${#item_array[@]} -eq 1 ]; then
	relativeitem=${item_array[0]}
elif [[ ${#item_array[@]} -gt 1 && "$isVFF" == '2' || "$isVFF" == '3' ]]; then
	for file in ${item_array[@]}
	do
		selectitem=''
		selectitem=`pwd`/$file
		checkline=`grep $selectitem $fast_change_dir_project_config/vimlist-$groupname.txt | wc -l`
		if [ "$checkline" -lt 1 ]; then
			echo "\"$selectitem\"" >> $fast_change_dir_project_config/vimlist-$groupname.txt
		fi
	done
	relativeitem='__empty'
elif [ ${#item_array[@]} -gt 1 ]; then
	tmpfile="$fast_change_dir_tmp/`whoami`-vf-dialog-select-only-file-$( date +%Y%m%d-%H%M ).txt"
	dialogitems=""
	for echothem in ${item_array[@]}
	do
		dialogitems=" $dialogitems $echothem '' "
	done
	cmd=$( func_dialog_menu '請從裡面挑一項你所要的' 100 "$dialogitems" $tmpfile )

	eval $cmd
	result=`cat $tmpfile`

	if [ -f "$tmpfile" ]; then
		rm -rf $tmpfile
	fi

	if [ "$result" != "" ]; then
		relativeitem=$result
	else
		relativeitem=''
	fi
else
	relativeitem=''
fi

if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
	if [ "$isVFF" == '0' ]; then
		inputchar='n'
	elif [ "$isVFF" == '1' ]; then
		inputchar='y'
	elif [ "$isVFF" == '2' ]; then
		inputchar='y'
	elif [ "$isVFF" == '3' ]; then
		inputchar='n'
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
	if [ "$relativeitem" != '__empty' ]; then
		selectitem=''
		selectitem=`pwd`/$relativeitem
		checkline=`grep "$selectitem" $fast_change_dir_project_config/vimlist-$groupname.txt | wc -l`
		if [ "$checkline" -lt 1 ]; then
			echo "\"$selectitem\"" >> $fast_change_dir_project_config/vimlist-$groupname.txt
		else
			echo '[NOTICE] File is exist'
		fi
	fi

	if [[ "$inputchar" == 'y' || "$inputchar" == "1" ]]; then
		# 取得最後append的檔案位置，這樣子vim -p以後就可以直接跳過該位置，就不用一直在gt..gt..gt..gt...
		checklinenumber=`cat $fast_change_dir_project_config/vimlist-$groupname.txt | nl -w1 -s: | grep "$selectitem" | head -n 1 | awk -F: '{print $1}'`
		cmd='vff "vim'

		# 不知道為什麼不能超過10，超過會出現以下的錯誤訊息
		# 太多 "+command" 、 "-c command" 或 "--cmd command" 參數
		# 查詢更多資訊請執行: "vim -h"

		# 為了加快速度而這麼寫的
		tabennn=('' '+tabnext' '+tabnext +tabnext' '+tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext' '+tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext +tabnext')
		if [ "$checklinenumber" -lt 10 ]; then
			cmd="$cmd ${tabennn[$checklinenumber]}"
			echo $cmd
		elif [[ "$checklinenumber" -ge 10 && "$checklinenumber" -lt 18 ]]; then
			# 先把編輯清單陣列1~8(從0開始)清掉，把10到19補進來
			# 位置0是所開始的檔案列表
			for i in {0..7}
			do
				unset item_array[$i]
			done

			# 在這裡，只是準備好tabenext的數量，剩下的工作會交給vimlist2.sh
			cmd="$cmd ${tabennn[$(expr $checklinenumber - 8)]}"
		elif [[ "$checklinenumber" -ge 18 && "$checklinenumber" -lt 27 ]]; then
			for i in {0..16}
			do
				unset item_array[$i]
			done

			# 在這裡，只是準備好tabenext的數量，剩下的工作會交給vimlist2.sh
			cmd="$cmd ${tabennn[$(expr $checklinenumber - 17)]}"
		elif [[ "$checklinenumber" -ge 27 && "$checklinenumber" -lt 36 ]]; then
			for i in {0..25}
			do
				unset item_array[$i]
			done

			# 在這裡，只是準備好tabenext的數量，剩下的工作會交給vimlist2.sh
			cmd="$cmd ${tabennn[$(expr $checklinenumber - 26)]}"
		else
			echo '[NOTICE] 不要超過35個以上(不含35)的編輯檔案'
			echo '[NOTICE] 純編輯這個檔案，以及叫出列表，看你要砍掉哪一個'
			vim "$selectitem"

			unset cmd
			unset cmd1
			unset cmd2
			unset cmd3
			unset number
			unset item_array
			unset checklinenumber
			unset relativeitem
			unset selectitem

			vfff
			cmd=''
		fi

		if [ "$cmd" != '' ]; then
			cmd="$cmd -p $fast_change_dir_project_config/vimlist-$groupname.txt\""
			eval $cmd
		fi
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
