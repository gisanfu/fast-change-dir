#!/bin/bash

# default ifs value 
default_ifs=$' \t\n'

# 在這裡，優先權最高的(我指的是按.優先選擇的項目)
# 是檔案(^D) > 資料夾(^F) > 上一層的檔案(^A) > 上一層的資料夾(^S)

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
	declare -a relativeitem

	# 先把英文轉成數字，如果這個欄位有資料的話
	fileposition=( `func_entonum "$fileposition"` )

	if [ "$fileposition" != '' ]; then
		newposition=$(($fileposition - 1))
		relativeitem=${relativeitem[$newposition]}
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

		if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
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
	elif [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
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
unset item_file_array
unset item_dir_array
unset item_parent_file_array
unset item_parent_dir_array

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# 倒退鍵
backspace=$(echo -e \\b\\c)

while [ 1 ];
do
	clear

	if [ "$condition" == '' ]; then
		echo 'SVN (英文字母)'
		echo '================================================='
		echo "現行資料夾: `pwd`"
		echo '================================================='
	fi

	ignorelist=$(func_getlsignore)
	cmd="ls -AF $ignorelist --color=auto"
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	fi

	echo '================================================='
	echo '基本快速鍵:'
	echo ' 離開 (?)'
	echo 'Svn功能快速鍵:'
	echo ' a. Status -q'
	echo ' b. Status'
	echo ' c. Update'
	echo ' d. Commit'
	echo '其它相關功能:'
	echo ' i. 以版本號編輯檔案 (別忘了使用前要先update一下) [需要ga]'
	echo '================================================='

	# 不加IFS=012的話，我輸入空格，read variable是讀不到的
	read -s -n 1 inputvar

	if [ "$inputvar" == '?' ]; then
		# 離開
		clear
		break
	elif [[ "$inputvar" == 'a' || "$inputvar" == 'A' ]]; then
		svn status -q
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的SVN狀態，但不顯示問號的動作成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'b' || "$inputvar" == 'B' ]]; then
		svn status
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的SVN狀態成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'c' || "$inputvar" == 'C' ]]; then
		svn update
		if [ "$?" -eq 0 ]; then
			echo '更新本SVN資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'd' || "$inputvar" == 'D' ]]; then
		echo '要送出了，但是請先輸入changelog，別忘了要大於5個字元，輸入完請按Enter'
		read changelog
		if [ "$changelog" == '' ]; then
			echo '為什麼你沒有輸入changelog呢？還是我幫你填上預設值呢？(no comment)好嗎？[Yj1,nf0]'
			read inputvar2
			if [[ "$inputvar2" == 'y' || "$inputvar2" == 'j' || "$inputvar2" == "1" ]]; then
				changelog='no comment'
			elif [[ "$inputvar2" == 'n' || "$inputvar2" == "f" || "$inputvar2" == "0" ]]; then
				echo '如果不要預設值，那就算了'
			else
				echo '不好意思，不要預設值也不要來亂'
			fi
		fi
		if [ "$changelog" == '' ]; then
			echo '你並沒有輸入changelog，所以下次在見了，本次動作取消，倒數3秒後離開'
			sleep 3
		else
			svn commit -m "$changelog"
			changelog=''
			if [ "$?" -eq 0 ]; then
				echo 'Commit成功'
			fi
			echo '按任何鍵繼續...'
			read -n 1
		fi
	elif [[ "$inputvar" == 'i' || "$inputvar" == 'I' ]]; then
		. /bin/gisanfu-dirpoint.sh root && svn log -v | more && /bin/gisanfu-svn-edit-revision.sh && cd -
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
