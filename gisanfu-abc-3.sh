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

func_dirpoint()
{
	dirpoint=$1

	if [[ "$groupname" != '' && "$dirpoint" != '' ]]; then
		resultarray=(`grep ^$dirpoint[[:alnum:]]*, ~/gisanfu-dirpoint-$groupname.txt | cut -d, -f1`)
		echo ${resultarray[@]}
	fi
}

func_groupname()
{
	groupname=$1

	resultarray=(`grep $groupname ~/gisanfu-groupname.txt`)
	echo ${resultarray[@]}
}

# 呼叫這個函式的前面，別忘了要加上至少3個字母的判斷式
func_search()
{
	keyword=$1
	second=$2
	position=$3

	declare -a resultarray
	declare -a resultarraytmp

	# 先把英文轉成數字，如果這個欄位有資料的話
	position=( `func_entonum "$position"` )

	if [ "$position" != '' ]; then
		newposition=$(($position - 1))
	fi

	if [ "$keyword" != '' ]; then
		if [ "$groupname" != '' ]; then
			# 先取得root資料夾位置
			dirpoint_roots=(`cat ~/gisanfu-dirpoint-$groupname.txt | grep ^root | head -n 1 | tr "," " "`)
			path=${dirpoint_roots[1]}
		else
			path='.'
		fi

		cmd="find $path -iname \*$keyword\* -type f"

		if [ "$second" != '' ]; then
			cmd="$cmd | grep $second"
		fi

		num=0
		IFS=$'\n'
		resultarraytmp=(`eval $cmd`)
		for i in ${resultarraytmp[@]}
		do
			# 為了要解決空白檔名的問題
			resultarray[$num]=`echo $i|sed 's/ /___/g'`
			num=$num+1
		done
		IFS=$default_ifs
		num=0

		if [ "${#resultarray[@]}" -gt 0 ]; then
			if [ "$newposition" == '' ]; then
				echo ${resultarray[@]:0:5}
			else
				# 先把含空格的文字，轉成陣列
				aaa=(${resultarray[@]:0:5})
				# 然後在指定位置輸出
				echo ${aaa[$newposition]}
			fi
		fi
	fi
}

unset condition
unset cmd1
unset cmd2
unset cmd3
unset item_file_array
unset item_dir_array
unset item_parent_file_array
unset item_parent_dir_array
unset item_dirpoint_array
unset item_groupname_array
unset item_search_array

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# 倒退鍵
backspace=$(echo -e \\b\\c)

color_txtgrn='\e[0;32m' # Green
color_none='\e[0m' # No Color

while [ 1 ];
do
	clear

	if [ "$first" == '1' ]; then
		echo '即時切換資料夾 (關鍵字)'
		echo '================================================='
	fi

	echo "\"$groupname\" || `pwd`"
	echo '================================================='

	ignorelist=$(func_getlsignore)
	cmd="ls -AF $ignorelist --color=auto"
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: \"$condition\""
	fi


	if [ "$first" == '1' ]; then
		echo '================================================='
		echo -e "${color_txtgrn}基本快速鍵:${color_none}"
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (.) 句點'
		echo ' 上一層 (,) 逗點'
		echo " 到數字切換資料夾功能 (') 單引號"
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}選擇用的快速鍵:${color_none}"
		echo ' 單項檔案 (F) 大寫F shift+f'
		echo ' 單項資料夾 (D)'
		echo ' 上一層單項檔案 (S)'
		echo ' 上一層單項資料夾 (A)'
		echo ' 專案捷徑名稱 (L)'
		echo ' 群組名稱 (G)'
		echo ' 搜尋檔案的結果 (H)'
		echo -e "${color_txtgrn}檔案操作類:${color_none}"
		echo ' Show Groupfile (I)'
		echo ' Edit Groupfile (J)'
		echo ' Clear Groupfile (K)'
		echo -e "${color_txtgrn}版本控制類:${color_none}"
		echo ' SVN (V)'
		echo ' GIT (T)'
		echo -e "${color_txtgrn}輸入條件的結構:${color_none}"
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
		first=''
	fi

	if [[ "${#item_file_array[@]}" -gt 0 || "${#item_dir_array[@]}" -gt 0 ]]; then
		echo '================================================='
	fi

	# 顯示重覆檔案
	if [ "${#item_file_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量(有多項的功能)[F]: 有${#item_file_array[@]}筆"
		number=1
		for bbb in ${item_file_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_file_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆哦[F]: ${item_file_array[0]}"
	fi

	# 顯示重覆資料夾
	if [ "${#item_dir_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: 有${#item_dir_array[@]}筆"
		number=1
		for bbb in ${item_dir_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦[D]: ${item_dir_array[0]}"
	fi

	# 為了直覺上，能夠快速的區分類別
	if [[ "${#item_parent_file_array[@]}" -gt 0 || "${#item_parent_dir_array[@]}" -gt 0 ]]; then
		echo '================================================='
	fi

	# 顯示重覆檔案(上一層)
	if [ "${#item_parent_file_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量 (有多項的功能) (上一層)[S]: 有${#item_parent_file_array[@]}筆"
		number=1
		for bbb in ${item_parent_file_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_parent_file_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆哦(上一層)[S]: ${item_parent_file_array[0]}"
	fi

	# 顯示重覆資料夾(上一層)
	if [ "${#item_parent_dir_array[@]}" -gt 1 ]; then
		echo "重覆的資料夾數量(上一層): 有${#item_parent_dir_array[@]}筆"
		number=1
		for bbb in ${item_parent_dir_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_parent_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦(上一層)[A]: ${item_parent_dir_array[0]}"
	fi

	# 為了直覺上，能夠快速的區分捷徑這個類別
	if [[ "${#item_dirpoint_array[@]}" -gt 0 ]]; then
		echo '================================================='
	fi

	# 顯示重覆的捷徑
	if [ "${#item_dirpoint_array[@]}" -gt 1 ]; then
		echo "重覆的捷徑: 有${#item_dirpoint_array[@]}筆"
		number=1
		for bbb in ${item_dirpoint_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_dirpoint_array[@]}" -eq 1 ]; then 
		echo "捷徑有找到一筆哦[L]: ${item_dirpoint_array[0]}"
	fi

	# 為了直覺上，能夠快速的區分群組名稱這個類別
	if [[ "${#item_groupname_array[@]}" -gt 0 ]]; then
		echo '================================================='
	fi

	# 顯示重覆的群組名稱
	if [ "${#item_groupname_array[@]}" -gt 1 ]; then
		echo "重覆的群組名稱: 有${#item_groupname_array[@]}筆"
		number=1
		for bbb in ${item_groupname_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_groupname_array[@]}" -eq 1 ]; then 
		echo "群組名稱有找到一筆哦[G]: ${item_groupname_array[0]}"
	fi

	if [[ "${#item_search_array[@]}" -gt 0 ]]; then
		echo '================================================='
	fi

	# 顯示重覆的搜尋結果項目
	if [ "${#item_search_array[@]}" -gt 1 ]; then
		echo "重覆的搜尋結果(有多項的功能)[H]: 有${#item_search_array[@]}筆"
		number=1
		for bbb in ${item_search_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_search_array[@]}" -eq 1 ]; then 
		echo "搜尋結果有找到一筆哦[H]: ${item_search_array[0]}"
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
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == ',' ]; then
		cd ..	
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == '.' ]; then
		if [ ${#item_file_array[@]} -eq 1 ]; then
			match=`echo ${item_file_array[0]} | sed 's/___/ /g'`
			if [ "$groupname" != '' ]; then
				run="vf \"$match\""
			else
				run="vim \"$match\""
			fi
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_dir_array[@]} -eq 1 ]; then
			match=`echo ${item_dir_array[0]} | sed 's/___/ /g'`
			run="cd \"$match\""
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_parent_file_array[@]} -eq 1 ]; then
			match=`echo ${item_parent_file_array[0]} | sed 's/___/ /g'`
			if [ "$groupname" != '' ]; then
				run="cd .. && vf \"$match\""
			else
				run="vim ../\"$match\""
			fi
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_parent_dir_array[@]} -eq 1 ]; then
			match=`echo ${item_parent_dir_array[0]} | sed 's/___/ /g'`
			run="cd ../\"$match\""
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_dirpoint_array[@]} -eq 1 ]; then
			match=`echo ${item_dirpoint_array[0]} | sed 's/___/ /g'`
			run="dv \"$match\""
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_groupname_array[@]} -eq 1 ]; then
			match=`echo ${item_groupname_array[0]} | sed 's/___/ /g'`
			run="ga \"$match\""
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		elif [ ${#item_search_array[@]} -eq 1 ]; then
			match=`echo ${item_search_array[0]} | sed 's/___/ /g'`
			if [ "${match:0:1}" == '.' ]; then
				run=". /bin/gisanfu-vimlist-append-with-path.sh \"\" \"$match\""
			else
				run=". /bin/gisanfu-vimlist-append-with-path.sh \"$match\" \"\""
			fi
			eval $run

			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			unset item_dirpoint_array
			unset item_groupname_array
			unset item_search_array
			continue
		fi
	elif [ "$inputvar" == 'F' ]; then
		if [ "${#item_file_array[@]}" -eq 1 ]; then
			match=`echo ${item_file_array[0]} | sed 's/___/ /g'`
			if [ "$groupname" != '' ]; then
				run="vf \"$match\""
			else
				run="vim \"$match\""
			fi
		elif [ "${#item_file_array[@]}" -gt 1 ]; then
			run=". /bin/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_file_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"$match\""
			done
		fi
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [[ "$inputvar" == 'D' && "${#item_dir_array[@]}" == 1 ]]; then
		match=`echo ${item_dir_array[0]} | sed 's/___/ /g'`
		run="cd \"$match\""
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'S' ]; then
		if [ "${#item_parent_file_array[@]}" -eq 1 ]; then
			match=`echo ${item_parent_file_array[0]} | sed 's/___/ /g'`
			if [ "$groupname" != '' ]; then
				# 會這樣子寫，是因為我的底層並沒有這個功能
				run="cd .. && vf \"$match\""
			else
				run="vim ../\"$match\""
			fi
		elif [ "${#item_parent_file_array[@]}" -gt 1 ]; then
			run=". /bin/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_parent_file_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"../$match\""
			done
		fi
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [[ "$inputvar" == 'A' && "${#item_parent_dir_array[@]}" == 1 ]]; then
		match=`echo ${item_parent_dir_array[0]} | sed 's/___/ /g'`
		run="g \"$match\""
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [[ "$inputvar" == 'L' && "${#item_dirpoint_array[@]}" == 1 ]]; then
		match=`echo ${item_dirpoint_array[0]} | sed 's/___/ /g'`
		run="dv \"$match\""
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [[ "$inputvar" == 'G' && "${#item_groupname_array[@]}" == 1 ]]; then
		match=`echo ${item_groupname_array[0]} | sed 's/___/ /g'`
		run="ga \"$match\""
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'H' ]; then
		if [ "${#item_search_array[@]}" -eq 1 ]; then
			match=`echo ${item_search_array[0]} | sed 's/___/ /g'`
			if [ "${match:0:1}" == '.' ]; then
				run=". /bin/gisanfu-vimlist-append-with-path.sh \"\" \"$match\""
			else
				run=". /bin/gisanfu-vimlist-append-with-path.sh \"$match\" \"\""
			fi
		elif [ "${#item_search_array[@]}" -gt 1 ]; then
			run=". /bin/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_search_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"$match\""
			done
		fi
		eval $run

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'I' ]; then
		vff

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'J' ]; then
		vfff

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'K' ]; then
		vffff

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'V' ]; then
		svnn

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	elif [ "$inputvar" == 'T' ]; then
		gitt

		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
		continue
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	elif [ "$inputvar" == "'" ]; then
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array

		. /bin/gisanfu-123-2.sh
		continue
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		cmds=($condition)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}
		# 第三個引數，是位置
		cmd3=${cmds[2]}

		item_file_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "file"` )
		item_dir_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "dir"` )
		item_parent_file_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" ".." "file"` )
		item_parent_dir_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" ".." "dir"` )

		# 長度大於3的關鍵字才能做搜尋的動作
		if [ "${#cmd1}" -gt 3 ]; then
			item_search_array=( `func_search "$cmd1" "$cmd2" "$cmd3" ` )
		fi

		# 有些功能，只要看到第2個引數就會失效
		if [ "$cmd2" == '' ]; then
			item_dirpoint_array=( `func_dirpoint "$cmd1"` )
			item_groupname_array=( `func_groupname "$cmd1"` )
		else
			unset item_dirpoint_array
			unset item_groupname_array
		fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_array
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
