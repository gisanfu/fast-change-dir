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

	# 要搜尋哪裡的路徑，空白代表現行目錄
	#lspath=$4

	# dir or file
	#filetype=$5

	declare -a itemList
	declare -a itemListTmp
	declare -a itemList2
	declare -a itemList2Tmp
	declare -a relativeitem

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
		#relativeitem=${relativeitem[$newposition]}
	fi

	# ignore file or dir
	#ignorelist=$(func_getlsignore)
	Success="0"

	#if [ "$filetype" == "dir" ]; then
	#	filetype_ls_arg=''
	#	filetype_grep_arg=''
	#else
	#	filetype_ls_arg='--file-type'
	#	filetype_grep_arg='-v'
	#fi

	# default ifs value
	default_ifs=$' \t\n'

	gitcmd=/usr/local/git/bin/git

	IFS=$'\n'
	declare -i num
	#itemListTmp=(`ls -AFL $ignorelist $filetype_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem` )
	itemListTmp=(`$gitcmd status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem`)
	for i in ${itemListTmp[@]}
	do
		# 為了要解決空白檔名的問題
		itemList[$num]=`echo $i|sed 's/ /___/g'`
		num=$num+1
	done
	IFS=$default_ifs
	num=0

	# use (^) grep fast, if no match, then remove (^)
	#if [ "${#itemList[@]}" -lt "1" ]; then

	#	IFS=$'\n'
	#	itemListTmp=(`ls -AFL $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem`)
	#	for i in ${itemListTmp[@]}
	#	do
	#		# 為了要解決空白檔名的問題
	#		itemList[$num]=`echo $i|sed 's/ /___/g'`
	#		num=$num+1
	#	done
	#	IFS=$default_ifs
	#	num=0

	#	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
	#		IFS=$'\n'
	#		itemList2Tmp=(`ls -AFL $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
	#		for i in ${itemList2Tmp[@]}
	#		do
	#			# 為了要解決空白檔名的問題
	#			itemList2[$num]=`echo $i|sed 's/ /___/g'`
	#			num=$num+1
	#		done
	#		IFS=$default_ifs
	#		num=0
	#	fi
	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
		IFS=$'\n'
		itemList2Tmp=(`$gitcmd status -s | grep -e '^ ' -e '^??' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
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

			#if [ "$secondCondition" == '' ]; then
			#	# if have duplicate dirname then CHDIR
			#	for dirDuplicatelist in ${itemList[@]}
			#	do
			#		# to match file or dir rule
			#		if [ "$dirDuplicatelist" == "$nextRelativeItem" ]; then
			#			relativeitem=$nextRelativeItem

			#			#func_statusbar 'USE-LUCK-ITEM'
		
			#			Success="1"
			#			break
			#		fi
			#	done
			#else
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

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# 倒退鍵
backspace=$(echo -e \\b\\c)

while [ 1 ];
do
	clear

	if [ "$first" == '1' ]; then
		echo 'Git Untracked List'
		echo '================================================='
	fi

	echo "\"$groupname\" || `pwd`"
	echo '================================================='

	#ignorelist=$(func_getlsignore)
	#cmd="ls -AF $ignorelist --color=auto"
	#eval $cmd
	gitcmd=/usr/local/git/bin/git
	cmd="$gitcmd status -s | grep -e '^ ' -e '^??'"
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: \"$condition\""
	fi

	if [ "$first" == '1' ]; then
		echo '================================================='
		echo '基本快速鍵:'
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (.) 句點'
		echo ' 離開 (?)'
		echo '輸入條件的結構:'
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
		first=''
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
		echo "檔案有找到一筆哦[F]: ${item_array[0]}"
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
			git add ${match:3}
			unset condition
			unset gitstatus 
			unset item_array
			continue
		fi
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		cmds=($condition)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}
		# 第三個引數，是位置
		cmd3=${cmds[2]}

		item_array=( `func_relative_by_git_append "$cmd1" "$cmd2" "$cmd3" "" "file"` )
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		unset condition
		unset gitstatus 
		unset item_array
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
