#!/bin/bash

func_relative()
{
	nextRelativeItem=$1
	secondCondition=$2
	# dir or file
	filetype=$3

	declare -a itemList
	declare -a itemList2

	if [ "$filetype" == "dir" ]; then
		filetype_ls_arg=''
		filetype_grep_arg=''
	else
		filetype_ls_arg='--file-type'
		filetype_grep_arg='-v'
	fi

	IFS=" "
	itemList=(`ls -AF -I .svn -I .git $filetype_ls_arg | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | tr -s "\n" " "` )

	# use (^) grep fast, if no match, then remove (^)
	if [ "${#itemList[@]}" -lt "1" ]; then
		itemList=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem`)
		if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
			itemList2=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi
	elif [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
		itemList2=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
	fi
	IFS=""


	# if empty of variable, then go back directory
	if [ "$nextRelativeItem" == "" ]; then
		#func_statusbar 'LOSS-ARG-RELATIVE'
		relativeitem=''
	else
		if [ "${#itemList[@]}" == "1" ]; then
			relativeitem=${itemList[0]}
			#func_statusbar 'USE-ITEM'
		elif [ "${#itemList[@]}" -gt "1" ]; then

			if [ "$secondCondition" == '' ]; then
				# if have duplicate dirname then CHDIR
				Success="0"
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
				fi
			fi
		else
			relativeitem=''
			#func_statusbar 'NOT-FOUND-OR-NOT-EXIST'
		fi
	fi

	echo $relativeitem
}

unset condition
unset cmd1
unset cmd2
unset item_file_array
unset item_dir_array

declare -a item_file_array
declare -a item_dir_array

while [ 1 ];
do
	clear
	echo "現行資料夾: `pwd`"
	echo '================================================='
	ls -AF -I .svn -I .git --color=auto

	if [ "$condition" != '' ]; then
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
		echo "檔案有找到一筆哦: ${item_file_array[0]}"
	fi

	# 顯示重覆資料夾
	if [ "${#item_dir_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_dir_array[@]}"
		for bbb in ${item_dir_array[@]}
		do
			echo $bbb
		done
	elif [ "${#item_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦: ${item_dir_array[0]}"
	fi

	read -s -n 1 inputvar

	if [ "$inputvar" == '/' ]; then
		unset condition
		unset item_file_array
		unset item_dir_array
		continue
	elif [ "$inputvar" == ',' ]; then
		cd ..	
		unset condition
		unset item_file_array
		unset item_dir_array
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
			continue
		elif [ ${#item_dir_array[@]} -eq 1 ]; then
			run="cd ${item_dir_array[0]}"
			eval $run
			unset condition
			unset item_file_array
			unset item_dir_array
			continue
		fi
	elif [[ "$inputvar" == 'D' && "${#item_dir_array[@]}" == 1 ]]; then
		run="cd ${item_dir_array[0]}"
		eval $run
		unset condition
		unset item_file_array
		unset item_dir_array
		continue
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
		continue
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		IFS=" "
		declare -a cmds
		cmds=(`echo $condition`)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}
		IFS=""

		item_dir=$( func_relative "$cmd1" "$cmd2" "dir" )
		item_file=$( func_relative "$cmd1" "$cmd2" "file" )

		item_dir_array=(`echo $item_dir`)
		item_file_array=(`echo $item_file`)
	fi
done
