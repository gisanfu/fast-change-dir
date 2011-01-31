#!/bin/bash

# 單純的把ls的忽略清單回傳而以
func_getlsignore()
{
	echo '-I .svn -I .git'
}

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
	declare -a itemList2
	declare -a itemList2Tmp
	declare -a itemreturn
	declare -a relativeitem

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
	fi

	# ignore file or dir
	ignorelist=$(func_getlsignore)
	Success="0"

	if [ "$filetype" == "dir" ]; then
		filetype_ls_arg=''
		filetype_grep_arg=''
	else
		filetype_ls_arg='--file-type'
		filetype_grep_arg='-v'
	fi

	# default ifs value
	default_ifs=$' \t\n'

	IFS=$'\n'
	declare -i num
	itemListTmp=(`ls -AFL $ignorelist $filetype_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem` )
	for i in ${itemListTmp[@]}
	do
		# 為了要解決空白檔名的問題
		itemList[$num]=`echo $i|sed 's/ /___/g'`
		num=$num+1
	done
	IFS=$default_ifs
	num=0

	# use (^) grep fast, if no match, then remove (^)
	if [ "${#itemList[@]}" -lt "1" ]; then

		IFS=$'\n'
		itemListTmp=(`ls -AFL $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem`)
		for i in ${itemListTmp[@]}
		do
			# 為了要解決空白檔名的問題
			itemList[$num]=`echo $i|sed 's/ /___/g'`
			num=$num+1
		done
		IFS=$default_ifs
		num=0

		if [[ "${#itemList[@]}" -ge 1 && "$secondCondition" != '' ]]; then
			IFS=$'\n'
			itemList2Tmp=(`ls -AFL $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
			for i in ${itemList2Tmp[@]}
			do
				# 為了要解決空白檔名的問題
				itemList2[$num]=`echo $i|sed 's/ /___/g'`
				num=$num+1
			done
			IFS=$default_ifs
			num=0
		fi
	elif [[ "${#itemList[@]}" -ge 1 && "$secondCondition" != '' ]]; then
		IFS=$'\n'
		itemList2Tmp=(`ls -AFL $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
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
			if [ "$secondCondition" == '' ]; then
				# if have duplicate dirname then CHDIR
				for dirDuplicatelist in ${itemList[@]}
				do
					# to match file or dir rule
					if [[ "$dirDuplicatelist" == "$nextRelativeItem/" || "$dirDuplicatelist" == "$nextRelativeItem" ]]; then
						relativeitem=$nextRelativeItem
						#func_statusbar 'USE-LUCK-ITEM'
						Success="1"
						break
					fi
				done
			else
				# if have secondCondition, DO secondCheck
				if [ "${#itemList2[@]}" == "1" ]; then
					relativeitem=${itemList2[0]}
					#func_statusbar 'USE-LUCK-ITEM-BY-SECOND-CONDITION'
					Success="1"
				elif [ "${#itemList2[@]}" -gt "1" ]; then 
					relativeitem=${itemList2[@]}
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
	else
		echo ''
	fi
}

func_relative2()
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
	if [ "$firstchar" == '@' ]; then
		isHeadSearch='^'
		nextRelativeItem=${nextRelativeItem:1}
	elif [ "$firstchar" == '#' ]; then
		nextRelativeItem=${nextRelativeItem:1}
	else
		firstchar=''
	fi
	echo $nextRelativeItem

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
			if [ "$firstchar" == '#' ]; then
				dialogitems=''
				for echothem in ${itemList[@]}
				do
					dialogitems=" $dialogitems $echothem '' "
				done
				cmd=$( func_dialog_menu '請從裡面挑一項你所要的' 100 "$dialogitems" $tmpfile )

				eval $cmd
				result=`cat $tmpfile`

				if [ -f "$tmpfile" ]; then
					rm -rf $tmpfile
				fi

				if [ "$result" == "" ]; then
					relativeitem=${itemList[@]}
				else
					echo $result
					exit
				fi
			else
				relativeitem=${itemList[@]}
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
	else
		echo ''
	fi
}

func_relative3()
{
	nextRelativeItem=$1

	# default ifs value
	default_ifs=$' \t\n'

	#IFS=$''
	echo ${nextRelativeItem:0:1}
	#IFS=$default_ifs
}

cmd1=$1
cmd2=$2
cmd3=$3

item_file_array=( `func_relative2 "$cmd1" "$cmd2" "$cmd3" "/home/gisanfu/test" "dir"` )

number=1
for bbb in ${item_file_array[@]}
do
	echo "$number. $bbb"
	number=$((number + 1))
done
