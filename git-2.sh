#!/bin/bash

source "$fast_change_dir_func/entonum.sh"

# default ifs value 
default_ifs=$' \t\n'

func_relative_by_git_append()
{
	nextRelativeItem=$1
	secondCondition=$2

	# 檔案的位置
	fileposition=$3

	# 顯示的方式，可能是untracked or tracked
	trackstatus=$4

	declare -a itemList
	declare -a itemListTmp
	declare -a itemList2
	declare -a itemList2Tmp
	declare -a relativeitem

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
	fi

	# ignore file or dir
	Success="0"

	# default ifs value
	default_ifs=$' \t\n'

	IFS=$'\n'
	declare -i num

	if [ "$trackstatus" == 'untracked' ]; then
		itemListTmp=(`git status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem`)
	else
		itemListTmp=(`git status -s | grep -e '^A' -e '^M' -e '^D' | grep -ir $nextRelativeItem`)
	fi

	for i in ${itemListTmp[@]}
	do
		# 為了要解決空白檔名的問題
		itemList[$num]=`echo $i|sed 's/ /___/g'`
		num=$num+1
	done
	IFS=$default_ifs
	num=0

	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then

		IFS=$'\n'

		if [ "$trackstatus" == 'untracked' ]; then
			itemList2Tmp=(`git status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		else
			itemList2Tmp=(`git status -s | grep -e '^A' -e '^M' -e '^D' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi

		for i in ${itemList2Tmp[@]}
		do
			# 為了要解決空白檔名的問題
			itemList2[$num]=`echo $i|sed 's/ /___/g'`
			num=$num+1
		done
		IFS=$default_ifs
		num=0
	fi

	# if empty of variable, then go back directory
	if [ "$nextRelativeItem" != "" ]; then
		if [ "${#itemList[@]}" == "1" ]; then
			relativeitem=${itemList[0]}
			#func_statusbar 'USE-ITEM'
		elif [ "${#itemList[@]}" -gt 1 ]; then

			if [ "$secondCondition" != '' ]; then
				# if have secondCondition, DO secondCheck
				if [ "${#itemList2[@]}" == "1" ]; then
					relativeitem=${itemList2[0]}

					#func_statusbar 'USE-LUCK-ITEM-BY-SECOND-CONDITION'
		
					Success="1"
				elif [ "${#itemList2[@]}" -gt "1" ]; then 
					relativeitem=${itemList2[@]}
					#relativeitem=$itemList2
					Success="1"
				fi
			fi

			# if no duplicate dirname then print them
			if [ $Success == "0" ]; then
				if [ "${#itemList2[@]}" -gt 0 ]; then
					relativeitem=${itemList2[@]}
				else
					relativeitem=${itemList[@]}
				fi
			fi
		fi
	fi

	# return array的標準用法
	if [ "$relativeitem" != '' ]; then
		if [ "$newposition" == '' ]; then
			echo ${relativeitem[@]}
		else
			# 先把含空格的文字，轉成陣列
			aaa=(${relativeitem[@]})
			# 然後在指定位置輸出
			echo ${aaa[$newposition]}
		fi
	fi
}

func_git_handle_status()
{
	item=$1

	# 不分兩次做，會出現前面少了一個空白，不知道為什麼
	match=`echo $item | sed 's/___/X/'`
	match=`echo $match | sed 's/___/ /g'`

	# 這個變數，存的可能是XD, DX, AX....
	gitstatus=${match:0:2}

	if [ "$untracked" == '1' ]; then
		if [ "$gitstatus" == 'XD' ]; then
			# 把檔案救回來
			git checkout ${match:3}
		else
			git add ${match:3}
		fi
	else
		if [ "$gitstatus" == 'DX' ]; then
			# 把檔案救回來
			git checkout HEAD ${match:3}
		else
			git reset ${match:3}
		fi
	fi
}

unset cmd1
unset cmd2
unset cmd3

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# 當符合某些條件以後，所以動作都要重來，這時需要清除掉某一些變數的內容
clear_var_all=''

# 倒退鍵
backspace=$(echo -e \\b\\c)

# 預設是顯示untracked列表
untracked='1'

while [ 1 ];
do
	clear

	if [[ "$first" == '1' || "$clear_var_all" == '1' ]]; then
		unset cmd
		unset condition
		unset item_array
		clear_var_all=''
		first=''
	fi

	echo 'Git (關鍵字)'
	echo '================================================='
	echo "\"$groupname\" || `pwd`"
	echo '================================================='
	if [ "$untracked" == '1' ]; then
		echo "Untracked List"
	else
		echo "Tracked List"
	fi
	echo '================================================='

	if [ "$untracked" == '1' ]; then
		cmd="git status -s | grep -e '^ ' -e '^??'"
	else
		cmd="git status -s | grep -e '^A' -e '^M' -e '^D' -e '^R'"
	fi
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: \"$condition\""
	fi

	if [ "$condition" == '' ]; then
		echo '================================================='
		echo -e "${color_txtgrn}基本快速鍵:${color_none}"
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (;) 分號'
		echo ' 處理多項(*) 星號'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}Git功能快速鍵:${color_none}"
		echo ' Change Untracked or Tracked (A)'
		echo ' Commit(keyin changelog, and send by ask!) (C)'
		echo ' Push(send!!) (E)'
		echo ' Update(Pull) (U)'
		#echo -e "${color_txtgrn}選擇用的快速鍵:${color_none}"
		#echo ' 是否加入 (B)'
		#echo ' 是否刪除 (D)'
		echo '輸入條件的結構:'
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
	fi

	echo '================================================='

	# 顯示重覆檔案
	if [ "${#item_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_array[@]} [*]"
		number=1
		for bbb in ${item_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆: ${item_array[0]} [;.]"
	fi

	# 不加IFS=012的話，我輸入空格，read variable是讀不到的
	IFS=$'\012'
	read -s -n 1 inputvar
	IFS=$default_ifs

	if [ "$inputvar" == '?' ]; then
		# 離開
		clear
		break
	elif [ "$inputvar" == '/' ]; then
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == ';' || "$inputvar" == '.' ]]; then
		if [ ${#item_array[@]} -eq 1 ]; then
			func_git_handle_status "${item_array[0]}"
			clear_var_all='1'
			continue
		fi
	elif [ "$inputvar" == '*' ]; then
		if [ "${#item_array[@]}" -gt 1 ]; then
			for bbb in ${item_array[@]}
			do
				func_git_handle_status "$bbb"
			done
			clear_var_all='1'
			continue
		fi
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	elif [ "$inputvar" == 'A' ]; then
		if [ "$untracked" == '1' ]; then
			untracked='0'
		else
			untracked='1'
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'C' ]; then
		echo '要送出了，但是請先輸入changelog，輸入完請按Enter'
		read changelog
		if [ "$changelog" == '' ]; then
			echo '為什麼你沒有輸入changelog呢？還是我幫你填上預設值呢？(no comment)好嗎？[Y1,n0]'
			read inputvar2
			if [[ "$inputvar2" == 'y' || "$inputvar2" == "1" ]]; then
				changelog='no comment'
			elif [[ "$inputvar2" == 'n' || "$inputvar2" == "0" ]]; then
				echo '如果不要預設值，那就算了'
			else
				echo '不好意思，不要預設值也不要來亂'
			fi
		fi
		if [ "$changelog" == '' ]; then
			echo '你並沒有輸入changelog，所以下次在見了，本次動作取消，倒數3秒後離開'
			sleep 3
		else
			git commit -m "$changelog"
			changelog=''
			if [ "$?" -eq 0 ]; then
				#echo '設定Changelog成功，別忘了要選擇送出哦'
				echo '要不要送出(git push)呢？[Y1,n0]'
				read inputvar3
				if [[ "$inputvar3" == 'n' || "$inputvar3" == "0" ]]; then
					echo '不要送出的話，那就算了！'
				else
					git push
				fi
			fi
			echo '按任何鍵繼續...'
			read -n 1
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'U' ]; then
		echo '己送出更新(pull)指令，等待中...'
		git pull
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'E' ]; then
		echo '己送出push指令，等待中...'
		git push
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		clear_var_all='1'
		continue
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		cmds=($condition)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}
		# 第三個引數，是位置
		cmd3=${cmds[2]}

		if [ "$untracked" == '1' ]; then
			item_array=( `func_relative_by_git_append "$cmd1" "$cmd2" "$cmd3" "untracked"` )
		else
			item_array=( `func_relative_by_git_append "$cmd1" "$cmd2" "$cmd3" "tracked"` )
		fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		unset condition
		unset gitstatus 
		unset item_array
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
