#!/bin/bash

# IDEA
# 1. 按數字1，可能就顯示跟1有關係的項目，例如1、1N、1NN
# 2. filelist=all的時候，每一個項目都會加上數字，
#    當我選數字的時候，會自動去判斷這個項目是資料夾還是檔案

# 3種檔案變數
# 1.檔案顯示模式(mode)
#   指的是"ls -A"指令，要不要加上l
#   a.有l的是列出所有檔案(直式) - detail
#   b.沒有加的是跟著前面列出來(橫式) - normal
# 2.檔案列表方式(list)
#   a.顯示所有檔案和資料夾(不會加上任何的指令) - all
#   b.只顯示資料夾，後面也是會加上編號 - dir
#   c.只顯示檔案，檔案後面還會加上編號 - file
# 3.檔案指標種類(point)
#   這個應該不會在使用

func_relative()
{
	nextRelativeItem=$1
	secondCondition=$2
	# dir or file
	filetype=$3

	declare -a itemList
	declare -a itemList2
	#declare -a relativeitem 

	#echo "one $nextRelativeItem"
	#echo "second $secondCondition"

	if [ "$filetype" == "dir" ]; then
		filetype_ls_arg=''
		filetype_grep_arg=''
	else
		filetype_ls_arg='--file-type'
		filetype_grep_arg='-v'
	fi

	IFS=" "
	itemList=(`ls -AF -I .svn -I .git $filetype_ls_arg | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | tr -s "\n" " "` )
	#echo $itemList
	#echo "itemList數量 ${#itemList[@]}"

	# use (^) grep fast, if no match, then remove (^)
	if [ "${#itemList[@]}" -lt "1" ]; then
		itemList=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem`)
		if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
			itemList2=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi
	elif [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then
		#echo 'aaaaaaaaaaaaaaaaaaaaaaa'
		itemList2=(`ls -AF -I .svn -I .git $file_ls_arg | grep $filetype_grep_arg "/$" | grep -ir ^$nextRelativeItem | grep -ir $secondCondition`)
	fi
	IFS=""

	#echo $itemList2

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
		
			# if no duplicate dirname then print them
			#if [ $Success == "0" ]; then
			#	#dialogitems=''
			#	#for echothem in ${itemList[@]}
			#	#do
			#	#	dialogitems="$dialogitems \"$echothem\""
			#	#done

			#	relativeitem=$itemList

			#	#cmd=$( func_dialog_menu 'Please Select Item' 70 "$dialogitems" "$tmpfile" )

			#	#eval $cmd
			#	#result=`cat $tmpfile`

			#	#if [ -f "$tmpfile" ]; then
			#	#	rm -rf $tmpfile
			#	#fi
			#	#if [ "$result" == "" ]; then
			#	#	func_statusbar 'PLEASE-SELECT-ONE-ITEM'
			#	#	for echothem in ${itemList[@]}
			#	#	do
			#	#		echo $echothem
			#	#	done
			#	#else
			#	#	relativeitem=$result
			#	#fi
			#fi
		else
			relativeitem=''
			#func_statusbar 'NOT-FOUND-OR-NOT-EXIST'
		fi
	fi

	echo $relativeitem
}

#IFS=" "

unset condition
unset cmd1
unset cmd2
unset item_file_array
unset item_dir_array

while [ 1 ];
do
	clear
	echo "cmd1 $cmd1"
	echo "cmd2 $cmd2"
	echo $relativeitem
	echo $item_dir
	echo $item_file
	ls -AF -I .svn -I .git --color=auto

	if [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: $condition"
	fi

	echo '================================================='

	#if [[ "${#item_file_array[@]}" == 1 && "${#item_dir_array[@]}" == 1 ]]; then 
	#	echo '資料夾和檔案，都同時擁有1筆符合條件的，你要哪一個呢？'
	#	read -s -n 1 inputselectdirorfile
	#	if [ "$inputselectdirorfile" == 'd' ]; then
	#		d ${item_dir_array[0]}
	#	else
	#		if [ "$groupname" != '' ]; then
	#			vf ${item_file_array[0]}
	#		else
	#			vim ${item_file_array[0]}
	#		fi
	#	fi

	#	unset condition
	#	unset item_file_array
	#	unset item_dir_array
	#fi

	# 顯示重覆檔案
	if [ "${#item_file_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_file_array[@]}"
		for bbb in ${item_file_array[@]}
		do
			echo $bbb
		done
		#continue
	elif [ "${#item_file_array[@]}" == 1 ]; then 
		echo "檔案有找到一筆哦: ${item_file_array[0]}"
		#if [ "$groupname" != '' ]; then
		#	vf ${item_file_array[0]}
		#else
		#	vim ${item_file_array[0]}
		#fi
		#unset condition
		#unset item_file_array
		#unset item_dir_array
		#continue
	fi

	# 顯示重覆資料夾
	if [ "${#item_dir_array[@]}" -gt 1 ]; then
		echo "重覆的檔案數量: ${#item_dir_array[@]}"
		for bbb in ${item_dir_array[@]}
		do
			echo $bbb
		done
		#exit
	elif [ "${#item_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦: ${item_dir_array[0]}"
		#d ${item_dir_array[0]}
		#unset condition
		#unset item_file_array
		#unset item_dir_array
	fi

	read -s -n 1 inputvar

	if [ "$inputvar" == '/' ]; then
		unset condition
		unset item_file_array
		unset item_dir_array
		continue
	elif [ "$inputvar" == '-' ]; then
		ge
		unset condition
		unset item_file_array
		unset item_dir_array
		continue
	elif [[ "$inputvar" == 'D' && "${#item_dir_array[@]}" == 1 ]]; then
		run="d ${item_dir_array[0]}"
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

		#echo $item_dir
		#echo $item_file

		#for aaab in ${item_dir_array[@]}
		#do
		#	echo $aaab
		#done
		#sleep 20
	fi
done
