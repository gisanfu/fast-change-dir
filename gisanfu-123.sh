#!/bin/bash

# 數字切換資料夾的功能比較單純，
# 不會像英文模式一樣，檢查本層，同時也檢查上一層
# 顯示檔案，也會以ls -la來顯示


# 在這裡，優先權最高的(我指的是按.優先選擇的項目)
# 是檔案(^D) > 資料夾(^F) > 上一層的檔案(^A) > 上一層的資料夾(^S)

# 單純的把ls的忽略清單回傳而以
func_getLsIgnore()
{
	echo '-I .svn -I .git'
}

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

	ignorelist=$(func_getLsIgnore)

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

# default ifs value
default_ifs=$' \t\n'

while [ 1 ];
do
	clear

	if [ "$condition" == '' ]; then
		echo '即時切換資料夾 (數字)'
		echo '================================================='
		echo "現行資料夾: `pwd`"
		echo '================================================='
	fi

	# 避免現行資料夾裡面，只有一個item的狀況發生
	if [ "$condition" == '' ]; then
		item_array=( `func_lsItemAndNumber "" ""` )
	else
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
				continue
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
				continue
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
	elif [ "$condition" == '' ]; then
		echo '================================================='
		echo '快速鍵:'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (.)'
		echo ' 上一層 (-)'
		echo ' 到關鍵字切換資料夾功能 (+)'
		echo ' 離開 (*)'
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
	elif [ "$inputvar" == '.' ]; then
		other='0'
		continue
	elif [ "$inputvar" == '-' ]; then
		cd ..
		unset other 
		unset condition
		unset item_array
		continue
	elif [ "$inputvar" == '*' ]; then
		unset other 
		unset condition
		unset item_array
		# 離開
		clear
		break
	elif [ "$inputvar" == '+' ]; then
		unset other 
		unset condition
		unset item_array
		# 離開
		clear
		break
	fi

	condition="$condition$inputvar"
done

# 離開前，在顯示一下現在資料夾裡面的東西
ls -AF

if [ "$inputvar" == '+' ]; then
	abc
fi
