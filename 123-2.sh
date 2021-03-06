#!/bin/bash

source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/ignore.sh"

# 這個版本的新特色
# 1. 選擇完、或是選擇到以後，就會離開了
# 2. 可以輸入數字，與輸入英文的數字，不過主要還是輸入英文
# 3. 這個版本，主要是要配合英文模式所設計的

# 顯示現在的檔案，並且加上編號以及顏色
# 編號想要紅色，檔案各有各的顏色
func_lsItemAndNumber()
{
	lspath=$1
	# 檔案的位置，這個是數值(12345...)
	fileposition=$2
	# 是否顯示其它相關的數字，0是不顯示，預設是空白(顯示)
	other=$3

	# 都是粗體的顏色
	color_bldred='\e[1;31m' # Red
	color_bldgrn='\e[1;32m' # Green
	color_none='\e[0m' # No Color

	declare -a value_color 
	declare -a value_nocolor 
	# 加上數字的定義，下面的運算就可以很簡單
	declare -i loop_array_num
	declare -i loop_item_num

	ignorelist=$(func_getlsignore)

	cmd="ls -AFL1 $ignorelist $lspath" 

	# default ifs value
	default_ifs=$' \t\n'

	# 先取得沒有顏色的列表
	IFS=$'\n'
	list=(`eval $cmd`)
	for i in ${list[@]}
	do
		# 為了要解決空白檔名的問題
		list2[$loop_array_num]=`echo $i|sed 's/ /___/g'`
		loop_array_num=$loop_array_num+1
	done
	IFS=$default_ifs
	loop_array_num=0

	# 看是不是資料夾
	regex_isdir="^(.*)/$"

	for i in ${list2[@]}
	do
		# 如果開始的數字不符合，就會是0
		position_regex_match=''
		loop_item_num=$loop_item_num+1
		# 加上顏色的數字編號
		item_num_color="${color_bldred}${loop_item_num}${color_none}　"
		item_num_nocolor="${loop_item_num}　"

		if [ "$fileposition" != '' ]; then
			regex_match_startnum="^$fileposition"
			if [[ "$loop_item_num" =~ $regex_match_startnum ]]; then
				position_regex_match=''
			else
				position_regex_match='0'
			fi
		fi

		# 目前只做資料夾的顏色，和位置的標註
		if [[ "$i" =~ $regex_isdir && "$position_regex_match" != '0' ]]; then
			value_color[$loop_array_num]="${item_num_color}${color_bldgrn}${BASH_REMATCH[1]}${color_none}/"
			value_nocolor[$loop_array_num]="${item_num_nocolor}${BASH_REMATCH[1]}/"
		elif [ "$position_regex_match" != '0' ]; then
			value_color[$loop_array_num]="${item_num_color}$i${color_none}"
			value_nocolor[$loop_array_num]="${item_num_nocolor}$i"
		fi

		loop_array_num=$loop_array_num+1
	done

	regex_splitNumByFullSpace="^(.*)　(.*)$"

	if [ "${#value_color[@]}" == 1 ]; then
		if [ "$other" == '0' ]; then
			for i in ${value_nocolor[@]}
			do
				if [[ "$i" =~ $regex_splitNumByFullSpace ]]; then
					echo ${BASH_REMATCH[2]}
					break
				fi
			done
		else
			echo ${value_color[@]}
		fi

		#if [[ "${value_nocolor[@]}" =~ $regex_splitNumByFullSpace ]]; then
		#	echo ${BASH_REMATCH[2]}
		#fi
	else
		if [ "$other" == '0' ]; then
			for i in ${value_nocolor[@]}
			do
				if [[ "$i" =~ $regex_splitNumByFullSpace ]]; then
					echo ${BASH_REMATCH[2]}
					break
				fi
			done
		else
			echo ${value_color[@]}
		fi
	fi

	IFS=$default_ifs
}

unset other 
unset condition
unset item_array

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# default ifs value
default_ifs=$' \t\n'

while [ 1 ];
do
	clear

	if [ "$first" == '1' ]; then
		echo '即時切換資料夾 (數字) 切換後離開'
		echo '================================================='
	fi

	echo "\"$groupname\" || `pwd`"
	echo '================================================='

	# 避免現行資料夾裡面，只有一個item的狀況發生
	if [ "$condition" == '' ]; then
		item_array=( `func_lsItemAndNumber "" ""` )
	else
		# 先把英文轉成數字
		condition=( `func_entonum "$condition"` )

		item_array=( `func_lsItemAndNumber "" "$condition" "$other"` )

		if [ "${#item_array[@]}" == '1' ]; then
			# 如果是一筆，就重抓一次沒有顏色的一筆
			if [ "$other" == '' ]; then
				item_array=( `func_lsItemAndNumber "" "$condition" "0"` )
			fi

			regex_isdir="^(.*)/$"
			if [[ "${item_array[@]}" =~ $regex_isdir ]]; then
				match=`echo ${BASH_REMATCH[1]} | sed 's/___/ /g'`
				run="cd \"$match\""
				eval $run
				unset other 
				unset condition
				unset item_array
				break
			else
				match=`echo ${item_array[@]} | sed 's/___/ /g'`
				if [ "$groupname" == '' ]; then
					run="vim \"$match\""
				else
					run="vf \"$match\""
				fi
				eval $run
				unset other 
				unset condition
				unset item_array
				break	
			fi
		fi
	fi

	IFS=$'\n'
	echo -e "${item_array[*]}"
	IFS=$default_ifs

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: \"$condition\""
	fi

	if [ "$first" == '1' ]; then
		echo '================================================='
		echo '快速鍵:'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (;.)'
		echo ' 上一層 (-,)'
		echo ' 離開 (*?)'
		first=''
	fi

	echo '================================================='

	# 不加IFS=012的話，我輸入空格，read variable是讀不到的
	IFS=$'\012'
	read -s -n 1 inputvar
	IFS=$default_ifs

	if [ "$inputvar" == '/' ]; then
		unset other 
		unset condition
		unset item_array
		continue
	elif [[ "$inputvar" == '.' || "$inputvar" == ';' ]]; then
		other='0'
		continue
	elif [[ "$inputvar" == '-' || "$inputvar" == ',' ]]; then
		cd ..
		unset other 
		unset condition
		unset item_array
		continue
	elif [[ "$inputvar" == '*' || "$inputvar" == '?' ]]; then
		unset other 
		unset condition
		unset item_array
		# 離開
		clear
		break
	fi

	condition="$condition$inputvar"
done
