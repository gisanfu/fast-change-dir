#!/bin/bash

# 這個檔案，請試著用shc去編譯它
# 然後全面的把abc version3裡面的func_relative替換掉
# 試試看這樣子的效率有沒有比較快

# 結論就是沒有比較快，還是一樣很慢

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

#func_relative()
#{
	nextRelativeItem=$1
	secondCondition=$2

	# 檔案的位置
	fileposition=$3

	# 要搜尋哪裡的路徑，空白代表現行目錄
	lspath=$4

	# dir or file
	filetype=$5

	# get all item flag
	# 0 or empty: do not get all
	# 1: Get All
	isgetall=$6

	declare -a itemList
	declare -a itemListTmp
	declare -a relativeitem


	tmpfile="$fast_change_dir_tmp/`whoami`-function-relativeitem-$( date +%Y%m%d-%H%M ).txt"

	# ignore file or dir
	# ignorelist=$(func_getlsignore)
	ignorelist=''
	Success="0"

	# 試著使用@來決定第一個grep，從最開啟來找字串
	firstchar=${nextRelativeItem:0:1}
	isHeadSearch=''

	# 這裡要注意，不能夠使用井字號(#)來當做控制字元，會有問題
	if [ "$firstchar" == '@' ]; then
		isHeadSearch='^'
		nextRelativeItem=${nextRelativeItem:1}
	#elif [ "$firstchar" == '*' ]; then
	#	nextRelativeItem=${nextRelativeItem:1}
	else
		firstchar=''
	fi

	# 試著使用第二個引數的第一個字元，來判斷是不是position
	firstchar2=${secondCondition:0:1}

	if [[ "$firstchar2" == '@' && "$fileposition" == '' ]]; then
		fileposition=${secondCondition:1}
		secondCondition=''
	fi

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
	fi

	lucky=''
	if [ "$filetype" == "dir" ]; then
		filetype_ls_arg=''
		filetype_grep_arg=''
		if [[ -d "$lspath$nextRelativeItem" && "$isgetall" != '1' ]]; then
			echo "$nextRelativeItem"
			exit
		fi
	else
		filetype_ls_arg='--file-type'
		filetype_grep_arg='-v'
		if [[ -f "$lspath$nextRelativeItem" && "$isgetall" != '1' ]]; then
			echo "$nextRelativeItem"
			exit
		fi
	fi

	# default ifs value
	default_ifs=$' \t\n'

	IFS=$'\n'
	cmd="ls -AFL $ignorelist $filetype_ls_arg $lspath | grep  $filetype_grep_arg \"/$\""

	if [ "$isgetall" != '1' ]; then
		cmd="$cmd | grep -ir $isHeadSearch$nextRelativeItem"
	fi

	if [ "$secondCondition" != '' ]; then
		cmd="$cmd | grep -ir $secondCondition"
	fi

	# 取得項目列表，存到陣列裡面，當然也會做空白的處理
	declare -i num
	itemListTmp=(`eval $cmd`)
	for i in ${itemListTmp[@]}
	do
		# 為了要解決空白檔名的問題
		itemList[$num]=`echo $i|sed 's/ /___/g'`
		num=$num+1
	done
	IFS=$default_ifs
	num=0

	if [ "$nextRelativeItem" != "" ]; then
		if [ "${#itemList[@]}" == "1" ]; then
			relativeitem=${itemList[0]}
			#func_statusbar 'USE-ITEM'
		elif [ "${#itemList[@]}" -gt "1" ]; then
			relativeitem=${itemList[@]}
		fi
	fi

	if [ "$isgetall" == '1' ]; then
		if [ "${#itemList[@]}" == "1" ]; then
			relativeitem=${itemList[0]}
			#func_statusbar 'USE-ITEM'
		elif [ "${#itemList[@]}" -gt "1" ]; then
			relativeitem=${itemList[@]}
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
	else
		echo ''
	fi
#}
