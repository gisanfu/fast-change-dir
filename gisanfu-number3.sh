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

func_relative()
{
	nextRelativeItem=$1
	secondCondition=$2

	# 要搜尋哪裡的路徑，空白代表現行目錄
	lspath=$3

	# dir or file
	filetype=$4

	declare -a itemList
	declare -a itemList2
	declare -a relativeitem

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

	itemList=(`ls -AF $ignorelist $filetype_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem` )

	# use (^) grep fast, if no match, then remove (^)
	if [ "${#itemList[@]}" -lt "1" ]; then
		itemList=(`ls -AF $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem`)
		if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
			itemList2=(`ls -AF $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi
	elif [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
		itemList2=(`ls -AF $ignorelist $file_ls_arg $lspath | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
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
		echo ${relativeitem[@]}
	fi
}

unset condition
unset cmd1
unset cmd2
unset item_file_array
unset item_dir_array
unset item_parent_file_array
unset item_parent_dir_array

while [ 1 ];
do
	clear
	echo '即時切換資料夾'
	echo '================================================='
	echo "現行資料夾: `pwd`"
	echo '================================================='
	ignorelist=$(func_getlsignore)
	cmd="ls -AF $ignorelist --color=auto"
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: $condition"
	fi

	echo '================================================='

	# 顯示重覆檔案
	if [ "${#item_file_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_file_array[@]}"
		for bbb in ${item_file_array[@]}
		do
			echo $bbb
		done
	elif [ "${#item_file_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆哦[F]: ${item_file_array[0]}"
	fi

	# 顯示重覆資料夾
	if [ "${#item_dir_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_dir_array[@]}"
		for bbb in ${item_dir_array[@]}
		do
			echo $bbb
		done
	elif [ "${#item_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦[D]: ${item_dir_array[0]}"
	fi

	# 顯示重覆檔案(上一層)
	if [ "${#item_parent_file_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量(上一層): ${#item_parent_file_array[@]}"
		for bbb in ${item_parent_file_array[@]}
		do
			echo $bbb
		done
	elif [ "${#item_parent_file_array[@]}" -eq 1 ]; then 
		echo "檔案有找到一筆哦(上一層)[S]: ${item_parent_file_array[0]}"
	fi

	# 顯示重覆資料夾(上一層)
	if [ "${#item_parent_dir_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量(上一層): ${#item_parent_dir_array[@]}"
		for bbb in ${item_parent_dir_array[@]}
		do
			echo $bbb
		done
	elif [ "${#item_parent_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦(上一層)[A]: ${item_parent_dir_array[0]}"
	fi

	# 不加IFS=012的話，我輸入空格，read variable是讀不到的
	IFS=$'\012'
	read -s -n 1 inputvar
	IFS=$default_ifs

	if [ "$inputvar" == '?' ]; then
		# 離開
		break
	elif [ "$inputvar" == '/' ]; then
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	elif [ "$inputvar" == ',' ]; then
		cd ..	
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	elif [ "$inputvar" == '.' ]; then
		if [ ${#item_file_array[@]} -eq 1 ]; then
			if [ "$groupname" != '' ]; then
				run="vf ${item_file_array[0]}"
			else
				run="vim ${item_file_array[0]}"
			fi
			eval $run
			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			continue
		elif [ ${#item_dir_array[@]} -eq 1 ]; then
			run="cd ${item_dir_array[0]}"
			eval $run
			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			continue
		elif [ ${#item_parent_file_array[@]} -eq 1 ]; then
			if [ "$groupname" != '' ]; then
				run="cd .. && vf ${item_parent_file_array[0]}"
			else
				run="vim ../${item_parent_file_array[0]}"
			fi
			eval $run
			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			continue
		elif [ ${#item_parent_dir_array[@]} -eq 1 ]; then
			run="cd ../${item_parent_dir_array[0]}"
			eval $run
			unset condition
			unset item_file_array
			unset item_dir_array
			unset item_parent_file_array
			unset item_parent_dir_array
			continue
		fi
	elif [[ "$inputvar" == 'F' && "${#item_file_array[@]}" == 1 ]]; then
		if [ "$groupname" != '' ]; then
			run="vf ${item_file_array[0]}"
		else
			run="vim ${item_file_array[0]}"
		fi
		eval $run
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	elif [[ "$inputvar" == 'D' && "${#item_dir_array[@]}" == 1 ]]; then
		run="cd ${item_dir_array[0]}"
		eval $run
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	elif [[ "$inputvar" == 'S' && "${#item_parent_file_array[@]}" == 1 ]]; then
		if [ "$groupname" != '' ]; then
			# 會這樣子寫，是因為我的底層並沒有這個功能
			run="cd .. && vf ${item_parent_file_array[0]}"
		else
			run="vim ../${item_parent_file_array[0]}"
		fi
		eval $run
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	elif [[ "$inputvar" == 'A' && "${#item_parent_dir_array[@]}" == 1 ]]; then
		run="g ${item_parent_dir_array[0]}"
		eval $run
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		continue
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		cmds=($condition)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}

		item_file_array=( `func_relative "$cmd1" "$cmd2" "" "file"` )
		item_dir_array=( `func_relative "$cmd1" "$cmd2" "" "dir"` )
		item_parent_file_array=( `func_relative "$cmd1" "$cmd2" ".." "file"` )
		item_parent_dir_array=( `func_relative "$cmd1" "$cmd2" ".." "dir"` )
	fi

done
