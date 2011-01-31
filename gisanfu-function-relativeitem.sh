#!/bin/bash

# 單純的把ls的忽略清單回傳而以
func_getlsignore()
{
	echo '-I .svn -I .git'
}

func_relative()
{
	nextRelativeItem=$1
	secondCondition=$2

	# 檔案的位置
	fileposition=$3

	# 要搜尋哪裡的路徑，空白代表現行目錄
	lspath=$4

	# dir or file
	filetype=$5

	declare -a itemList
	declare -a itemListTmp
	declare -a relativeitem

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
	fi

	tmpfile=/tmp/`whoami`-function-relativeitem-$( date +%Y%m%d-%H%M ).txt

	# ignore file or dir
	ignorelist=$(func_getlsignore)
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

	lucky=''
	if [ "$filetype" == "dir" ]; then
		filetype_ls_arg=''
		filetype_grep_arg=''
		if [ -d "$lspath$nextRelativeItem" ]; then
			echo "$nextRelativeItem"
			exit
		fi
	else
		filetype_ls_arg='--file-type'
		filetype_grep_arg='-v'
		if [ -f "$lspath$nextRelativeItem" ]; then
			echo "$nextRelativeItem"
			exit
		fi
	fi

	# default ifs value
	default_ifs=$' \t\n'

	IFS=$'\n'
	cmd="ls -AFL $ignorelist $filetype_ls_arg $lspath | grep  $filetype_grep_arg \"/$\" | grep -ir $isHeadSearch$nextRelativeItem"
	if [ "$secondCondition" != '' ]; then
		cmd="$cmd | grep -ir $secondCondition"
	fi
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
			#if [ "$firstchar" == '*' ]; then
			#	dialogitems=''
			#	for echothem in ${itemList[@]}
			#	do
			#		dialogitems=" $dialogitems $echothem '' "
			#	done
			#	cmd=$( func_dialog_menu '請從裡面挑一項你所要的' 100 "$dialogitems" $tmpfile )

			#	eval $cmd
			#	result=`cat $tmpfile`

			#	if [ -f "$tmpfile" ]; then
			#		rm -rf $tmpfile
			#	fi

			#	if [ "$result" == "" ]; then
			#		relativeitem=${itemList[@]}
			#	else
			#		echo $result
			#		exit
			#	fi
			#else
			#	relativeitem=${itemList[@]}
			#fi
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
}
