#!/bin/bash

# 這是svn第3個版本
# 主要的特色是增加了svnlist的功能
# 可以只針對某一些檔案做送出
# 這個版本是不會去處理沖衝的狀態

# default ifs value 
default_ifs=$' \t\n'

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

func_relative_by_svn_append()
{
}

unset condition
unset cmd1
unset cmd2
unset cmd3
unset item_array
unset gitstatus 

# 倒退鍵
# Ctrl + h
backspace=$(echo -e \\b\\c)

# 這是模式
# 1. svn status, filter by untracked, or new file, 其它都沒有哦
# 2. svn status, filter by added, or deleted, modify一定會在裡面的(我想取commit list)
# 3. uncache list
# 4. cache list
mode='1'

while [ 1 ];
do
	clear

	echo 'Svn (關鍵字)'
	echo '================================================='
	echo "\"$groupname\" || `pwd`"
	echo '================================================='
	if [ "$mode" == '1' ]; then
		echo "Unknow File List"
	elif [ "$mode" == '2' ]; then
		echo "Commit List"
	elif [ "$mode" == '3' ]; then
		echo "Uncache List"
	elif [ "$mode" == '4' ]; then
		echo "Cache List"
	else
		# 為了誤動作，或是程式發生了未知的問題
		mode=1
		echo "Unknow File List"
	fi
	echo '================================================='

	if [ "$mode" == '1' ]; then
		# 問號是新的檔案，還未被新增進來，而驚嘆號是使用rm指令刪掉的狀況
		cmd="svn status | grep -e '^?' -e '^!'"
	elif [ "$mode" == '2' ]; then
		cmd="svn status | grep -e '^A' -e '^M' -e '^D'"
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
		echo ' 智慧選取單項 (.) 句點'
		echo ' 處理多項(*) 星號'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}Git功能快速鍵:${color_none}"
		echo ' Change Mode (A)'
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
		unset item_array
		continue
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	elif [ "$inputvar" == 'A' ]; then
		if [ "$mode" == '1' ]; then
			mode='2'
		elif [ "$mode" == '2' ]; then
			mode='3'
		elif [ "$mode" == '3' ]; then
			mode='4'
		elif [ "$mode" == '4' ]; then
			mode='1'
		fi
		unset condition
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

		#if [ "$untracked" == '1' ]; then
		#	item_array=( `func_relative_by_git_append "$cmd1" "$cmd2" "$cmd3" "untracked"` )
		#else
		#	item_array=( `func_relative_by_git_append "$cmd1" "$cmd2" "$cmd3" "tracked"` )
		#fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		unset condition
		unset item_array
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
