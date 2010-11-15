#!/bin/bash

# 把英文變成數字，例如er就是12
func_entonum()
{
	en=$1

	return=$en

	for i in ${en[@]}
	do
		return=`echo $return | sed 's/e/1/'`
		return=`echo $return | sed 's/r/2/'`
		return=`echo $return | sed 's/s/3/'`
		return=`echo $return | sed 's/f/4/'`
		return=`echo $return | sed 's/w/5/'`
		return=`echo $return | sed 's/l/6/'`
		return=`echo $return | sed 's/c/7/'`
		return=`echo $return | sed 's/b/8/'`
		return=`echo $return | sed 's/k/9/'`

		# 零
		return=`echo $return | sed 's/o/0/'`
		return=`echo $return | sed 's/z/0/'`
	done

	echo $return
}

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

	gitcmd=/usr/local/git/bin/git

	IFS=$'\n'
	declare -i num

	if [ "$trackstatus" == 'untracked' ]; then
		itemListTmp=(`$gitcmd status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem`)
	else
		itemListTmp=(`$gitcmd status -s | grep -e '^A' -e '^M' -e '^D' | grep -ir $nextRelativeItem`)
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
			itemList2Tmp=(`$gitcmd status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		else
			itemList2Tmp=(`$gitcmd status -s | grep -e '^A' -e '^M' -e '^D' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
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
		elif [ "${#itemList[@]}" -gt "1" ]; then

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

unset condition
unset cmd1
unset cmd2
unset cmd3
unset item_array
unset gitstatus 

# 倒退鍵
backspace=$(echo -e \\b\\c)

# 預設是顯示untracked列表
untracked='1'

while [ 1 ];
do
	clear

	echo 'Git (關鍵字)'
	echo '================================================='
	echo "\"$groupname\" || `pwd`"
	echo '================================================='
	echo "Untracked: $untracked"
	echo '================================================='

	#ignorelist=$(func_getlsignore)
	#cmd="ls -AF $ignorelist --color=auto"
	#eval $cmd
	gitcmd=/usr/local/git/bin/git
	if [ "$untracked" == '1' ]; then
		cmd="$gitcmd status -s | grep -e '^ ' -e '^??'"
	else
		cmd="$gitcmd status -s | grep -e '^A' -e '^M' -e '^D'"
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
		echo '基本快速鍵:'
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (.) 句點'
		echo ' 離開 (?)'
		echo 'Git功能快速鍵:'
		echo ' (A) Change Untracked or Tracked'
		echo ' (B)'
		echo ' (C) Update(Pull)'
		echo ' (D) Commit(keyin changelog, and send by ask!)'
		echo ' (E) Push(send!!)'
		echo '輸入條件的結構:'
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
	fi

	if [ "${#item_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆檔案
	if [ "${#item_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_array[@]}"
		number=1
		for bbb in ${item_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆: ${item_array[0]}"
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
		unset condition
		unset gitstatus 
		unset item_array
		continue
	elif [ "$inputvar" == '.' ]; then
		if [ ${#item_array[@]} -eq 1 ]; then
			# 不分兩次做，會出現前面少了一個空白，不知道為什麼
			match=`echo ${item_array[0]} | sed 's/___/X/'`
			match=`echo $match | sed 's/___/ /g'`

			if [ "$untracked" == '1' ]; then
				git add ${match:3}
			else
				git reset ${match:3}
			fi
			unset condition
			unset gitstatus 
			unset item_array
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
		unset condition
		unset gitstatus 
		unset item_array
		continue
	elif [ "$inputvar" == 'C' ]; then
		git pull
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		unset condition
		unset gitstatus 
		unset item_array
		continue
	elif [ "$inputvar" == 'D' ]; then
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
				if [[ "$inputvar2" == 'n' || "$inputvar2" == "0" ]]; then
					echo '不要送出的話，那就算了！'
				else
					git push
				fi
			fi
			echo '按任何鍵繼續...'
			read -n 1
		fi

		unset condition
		unset gitstatus 
		unset item_array
		continue
	elif [ "$inputvar" == 'E' ]; then
		git push
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		unset condition
		unset gitstatus 
		unset item_array
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
