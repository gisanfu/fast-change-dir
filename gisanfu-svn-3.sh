#!/bin/bash

# 這是svn第3個版本
# 主要的特色是增加了svnlist的功能
# 可以只針對某一些檔案做送出
# 這個版本是不會去處理沖衝的狀態

# default ifs value 
default_ifs=$' \t\n'

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

func_cache_controller()
{
	# cache的檔名也是用變數控制
	uncachefile=$1
	cachefile=$2

	modestatus=$3


	# 預設都是不動作的
	clear_cache='0'
	clear_uncache='0'
	generate_uncache='0'

	# default ifs value
	default_ifs=$' \t\n'

	if [ "$modestatus" == 'svn-status-to-uncache' ]; then
		generate_uncache='1'
		# 會清除，是因為是有相依性的
		clear_cache='1'
	elif [ "$modestatus" == 'clear-uncache' ]; then
		clear_uncache='1'
		clear_cache='1'
	elif [ "$modestatus" == 'clear-cache' ]; then
		generate_uncache='1'
		# 會清除，是因為是有相依性的
		clear_cache='1'
	fi

	if [ "$generate_uncache" == '1' ]; then
		IFS=$'\n'
		declare -a itemList
		declare -a itemListTmp
		declare -i num

		itemListTmp=(`svn status | grep -e '^A' -e '^M' -e '^D'`)

		cmd="rm $uncachefile"
		eval $cmd

		for i in ${itemListTmp[@]}
		do
			# 解決狀態與物件間的7個空白
			# XXXXXXXXXXXXXXXXXXXXXXXX1234567X
			handle1=`echo $i | sed 's/       /___/'`
			handle2=`echo $handle1 | sed 's/ /___/g'`
			# 為了要解決空白檔名的問題
			itemList[$num]=$handle2
			num=$num+1
		done
		num=0

		for bbb in ${itemList[@]}
		do
			cmd="echo '\"$bbb\"' >> $uncachefile"
			eval $cmd
		done

		IFS=$default_ifs
	fi

	if [ "$clear_cache" == '1' ]; then
		cmd="rm $cachefile"
		eval $cmd
		cmd="touch $cachefile"
		eval $cmd
	fi

	if [ "$clear_uncache" == '1' ]; then
		cmd="rm $uncachefile"
		eval $cmd
		cmd="touch $uncachefile"
		eval $cmd
	fi

}

func_relative_by_svn_append()
{
	nextRelativeItem=$1
	secondCondition=$2

	# 檔案的位置
	fileposition=$3

	# 顯示的方式，可能是untracked or tracked
	modestatus=$4

	# cache的檔名也是用變數控制
	uncachefile=$5
	cachefile=$6

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
	Success="0"

	# default ifs value
	default_ifs=$' \t\n'

	IFS=$'\n'
	declare -i num

	if [ "$modestatus" == 'unknow' ]; then
		itemListTmp=(`svn status | grep -e '^?' -e '^!' | grep -ir $nextRelativeItem`)
	elif [ "$modestatus" == 'commit' ]; then
		itemListTmp=(`svn status | grep -e '^A' -e '^D' | grep -ir $nextRelativeItem`)
	elif [ "$modestatus" == 'uncache' ]; then
		cmd="cat $uncachefile | grep -ir $nextRelativeItem"
		itemListTmp=(`eval $cmd`)
	elif [ "$modestatus" == 'cache' ]; then
		cmd="cat $cachefile | grep -ir $nextRelativeItem"
		itemListTmp=(`eval $cmd`)
	fi

	for i in ${itemListTmp[@]}
	do
		# 解決狀態與物件間的7個空白
		# XXXXXXXXXXXXXXXXXXXXXXXX1234567X
		handle1=`echo $i | sed 's/       /___/'`
		handle2=`echo $handle1 | sed 's/ /___/g'`
		# 為了要解決空白檔名的問題
		itemList[$num]=$handle2
		num=$num+1
	done
	IFS=$default_ifs
	num=0

	if [[ "${#itemList[@]}" -gt "1" && "$secondCondition" != '' ]]; then

		IFS=$'\n'

		if [ "$modestatus" == 'unknow' ]; then
			itemList2Tmp=(`svn status | grep -e '^?' -e '^!' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'commit' ]; then
			itemList2Tmp=(`svn status | grep -e '^A' -e '^D' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'uncache' ]; then
			itemList2Tmp=(`cat $uncachefile | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'cache' ]; then
			itemList2Tmp=(`cat $cachefile | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi

		for i in ${itemList2Tmp[@]}
		do
			# 解決狀態與物件間的7個空白
			# XXXXXXXXXXXXXXXXXXXXXXXX1234567X
			handle1=`echo $i | sed 's/       /___/'`
			handle2=`echo $handle1 | sed 's/ /___/g'`
			# 為了要解決空白檔名的問題
			itemList2[$num]=$handle2
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
		elif [ "${#itemList[@]}" -gt 1 ]; then

			if [ "$secondCondition" != '' ]; then
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
unset cmd
unset cmd1
unset cmd2
unset cmd3
unset svnstatus
unset item_unknow_array
unset item_commit_array
unset item_uncache_array
unset item_cache_array

# 倒退鍵
# Ctrl + h
backspace=$(echo -e \\b\\c)

# 這是模式，前面的括號是該模式的別名
# 1. [unknow] svn status, filter by untracked, or new file, 其它都沒有哦
# 2. [commit] svn status, filter by added, or deleted, modify一定會在裡面的(我想取commit list)
# 3. [uncache] uncache list
# 4. [cache] cache list
mode='1'

uncachefile='~/gisanfu-svn3-uncache.txt'
cachefile='~/gisanfu-svn3-cache.txt'

# 清理uncache的同時，也會一並清除cache，因為它們是有相依性的
func_cache_controller "$uncachefile" "$cachefile" "clear-uncache"

while [ 1 ];
do
	clear

	echo 'Svn (關鍵字)'
	echo '================================================='
	echo "\"$groupname\" || `pwd`"
	echo '================================================='
	if [ "$mode" == '1' ]; then
		echo "Unknow File List"
	elif [ "$mode" == '2' ]; then
		echo "Commit List"
	elif [ "$mode" == '3' ]; then
		echo "Uncache List"
	elif [ "$mode" == '4' ]; then
		echo "Cache List"
	else
		# 為了誤動作，或是程式發生了未知的問題
		mode=1
		echo "Unknow File List"
	fi
	echo '================================================='

	if [ "$mode" == '1' ]; then
		# 問號是新的檔案，還未被新增進來，而驚嘆號是使用rm指令刪掉的狀況
		cmd="svn status | grep -e '^?' -e '^!'"
	elif [ "$mode" == '2' ]; then
		cmd="svn status | grep -e '^A' -e '^M' -e '^D'"
	elif [ "$mode" == '3' ]; then
		cmd="cat $uncachefile"
	elif [ "$mode" == '4' ]; then
		cmd="cat $cachefile"
	fi
	eval $cmd

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		echo '================================================='
		echo "目前您所輸入的搜尋條件: \"$condition\""
	fi

	if [ "$condition" == '' ]; then
		echo '================================================='
		echo -e "${color_txtgrn}基本快速鍵:${color_none}"
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (.) 句點'
		echo ' 處理多項(*) 星號'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}Svn功能快速鍵:${color_none}"
		echo ' Change Normal Mode (A)'
		echo ' Change Cache Mode (B)'
		echo ' Commit (C)'
		echo ' Delete Cache/Uncache (D)'
		echo ' Generate Uncache (G)'
		echo ' Update (U)'
		#echo -e "${color_txtgrn}選擇用的快速鍵:${color_none}"
		#echo ' 是否加入 (B)'
		#echo ' 是否刪除 (D)'
		echo '輸入條件的結構:'
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
	fi

	echo '================================================='

	# 顯示重覆的SVN未知檔案
	if [ "${#item_unknow_array[@]}" -gt 1 ]; then
		echo "重覆的未知SVN檔案數量: ${#item_unknow_array[@]} [*]"
		number=1
		for bbb in ${item_unknow_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_unknow_array[@]}" -eq 1 ]; then 
		echo "未知的SVN檔案有找到一筆: ${item_unknow_array[0]} [.]"
	fi

	# 顯示己經準備送出，而且狀態是新增、與刪除
	if [ "${#item_commit_array[@]}" -gt 1 ]; then
		echo "重覆的準備送出的SVN，狀態為A與D的檔案數量: ${#item_commit_array[@]} [*]"
		number=1
		for bbb in ${item_commit_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_commit_array[@]}" -eq 1 ]; then 
		echo "準備送出的SVN，狀態為A與D的檔案有找到一筆: ${item_commit_array[0]} [.]"
	fi

	# 顯示Uncache項目
	if [ "${#item_uncache_array[@]}" -gt 1 ]; then
		echo "重覆的Uncache檔案數量: ${#item_uncache_array[@]} [*]"
		number=1
		for bbb in ${item_uncache_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_uncache_array[@]}" -eq 1 ]; then 
		echo "Uncache檔案有找到一筆: ${item_uncache_array[0]} [.]"
	fi

	# 顯示Cache項目
	if [ "${#item_cache_array[@]}" -gt 1 ]; then
		echo "重覆的Cache檔案數量: ${#item_cache_array[@]} [*]"
		number=1
		for bbb in ${item_cache_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_cache_array[@]}" -eq 1 ]; then 
		echo "Cache檔案有找到一筆: ${item_cache_array[0]} [.]"
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
		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	elif [ "$inputvar" == 'A' ]; then
		if [ "$mode" == '1' ]; then
			mode='2'
		elif [ "$mode" == '2' ]; then
			mode='1'
		else
			mode='1'
		fi

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == 'B' ]; then
		if [ "$mode" == '3' ]; then
			mode='4'
		elif [ "$mode" == '4' ]; then
			mode='3'
		else
			mode='3'
		fi

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == 'C' ]; then
		if [[ "$mode" == '2' || "$mode" == '4' ]]; then
			echo '要送出囉，但是請先輸入changelog，輸入完按Enter後直接送出'
			read changelog

			if [ "$changelog" == '' ]; then
				echo '為什麼你沒有輸入changelog呢？還是我幫你填上預設值呢？(no comment)好嗎？[Y1,n0]'
				read inputvar2
				if [[ "$inputvar2" == 'y' || "$inputvar2" == "1" ]]; then
					changelog='no comment'
				elif [[ "$inputvar2" == 'n' || "$inputvar2" == "0" ]]; then
					echo '如果不要預設值，那就算了'
				else
					echo '不好意思，不要預設值也不要來亂'
				fi
			fi

			if [ "$changelog" == '' ]; then
				echo '你並沒有輸入changelog，所以下次在見了，本次動作取消，倒數3秒後離開'
				sleep 3
			else
				cmd="svn commit -m \"$changelog\" "

				if [ "$mode" == '4' ]; then
					cmdcat="cat $cachefile | wc -l"
					cmdcount=`eval $cmdcat`

					if [ "$cmdcount" -ge 1 ]; then
						cmdlist="cat $cachefile | tr '\n' ' '"
						cmdlist2=`eval $cmdlist`


						IFS=$'\n'
						cmdlist="cat $cachefile"
						cmdlist2=(`eval $cmdlist`)
						cmdlist3=''

						for i in ${cmdlist2[@]}
						do
							# 不分兩次做，會出現前面少了一個空白，不知道為什麼
							match=`echo ${i} | sed 's/___/X/'`
							match=`echo $match | sed 's/___/ /g'`
							cmdlist3="$cmdlist3 \"${match:3}"
						done

						IFS=$default_ifs

						cmd="$cmd $cmdlist3"
					else
						echo '沒有可以送出的檔案，在cache裡面!!'
					fi
				fi

				eval $cmd
				changelog=''

				if [ "$?" -eq 0 ]; then
					echo '送出成功'
				else
					echo '送出失敗，請自行做檢查'
				fi

				echo '按任何鍵繼續...'
				read -n 1
			fi
		fi

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == 'D' ]; then
		if [ "$mode" == '3' ]; then
			func_cache_controller "$uncachefile" "$cachefile" "clear-uncache"
		elif [ "$mode" == '4' ]; then
			func_cache_controller "$uncachefile" "$cachefile" "clear-cache"
		fi

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == 'G' ]; then
		# 匯出後，自動跳到模式3，就是Uncache mode
		func_cache_controller "$uncachefile" "$cachefile" "svn-status-to-uncache"
		mode='3'

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == 'U' ]; then
		svn update
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		continue
	elif [ "$inputvar" == '.' ]; then
		if [ ${#item_unknow_array[@]} -eq 1 ]; then
			# 不分兩次做，會出現前面少了一個空白，不知道為什麼
			match=`echo ${item_unknow_array[0]} | sed 's/___/X/'`
			match=`echo $match | sed 's/___/ /g'`

			# 這個變數，存的可能是?、!
			svnstatus=${match:0:1}

			if [ "$svnstatus" == '?' ]; then
				svn add ${match:2}
			elif [ "$svnstatus" == '!' ]; then
				svn rm ${match:2}
			fi

			func_cache_controller "$uncachefile" "$cachefile" "svn-status-to-uncache"

			unset cmd
			unset condition
			unset svnstatus
			unset item_unknow_array
			unset item_commit_array
			unset item_uncache_array
			unset item_cache_array
			continue
		elif [ ${#item_commit_array[@]} -eq 1 ]; then
			# 不分兩次做，會出現前面少了一個空白，不知道為什麼
			match=`echo ${item_commit_array[0]} | sed 's/___/X/'`
			match=`echo $match | sed 's/___/ /g'`

			# 這個變數，存的可能是A、D
			svnstatus=${match:0:1}

			if [ "$svnstatus" == 'A' ]; then
				svn revert ${match:2}
			elif [ "$svnstatus" == 'D' ]; then
				svn revert ${match:2}
			fi

			func_cache_controller "$uncachefile" "$cachefile" "svn-status-to-uncache"

			unset cmd
			unset condition
			unset svnstatus
			unset item_unknow_array
			unset item_commit_array
			unset item_uncache_array
			unset item_cache_array
			continue
		elif [ ${#item_uncache_array[@]} -eq 1 ]; then
			cmd="grep '${item_uncache_array[0]}' $cachefile"
			tmp1=`eval $cmd`

			if [ "$tmp1" == '' ]; then
				cmd="echo '${item_uncache_array[0]}' >> $cachefile"
				eval $cmd
			fi

			# 先寫到暫存，然後在回寫回原來的檔案
			cmd="sed '/${item_uncache_array[0]}/d' $uncachefile > ${uncachefile}-tmp"
			eval $cmd
			cmd="cp ${uncachefile}-tmp $uncachefile"
			eval $cmd
			cmd="rm ${uncachefile}-tmp"
			eval $cmd

			unset cmd
			unset condition
			unset svnstatus
			unset item_unknow_array
			unset item_commit_array
			unset item_uncache_array
			unset item_cache_array
			continue
		elif [ ${#item_cache_array[@]} -eq 1 ]; then
			cmd="grep '${item_cache_array[0]}' $uncachefile"
			tmp1=`eval $cmd`

			if [ "$tmp1" == '' ]; then
				cmd="echo '${item_cache_array[0]}' >> $uncachefile"
				eval $cmd
			fi

			# 先寫到暫存，然後在回寫回原來的檔案
			cmd="sed '/${item_cache_array[0]}/d' $cachefile > ${cachefile}-tmp"
			eval $cmd
			cmd="cp ${cachefile}-tmp $cachefile"
			eval $cmd
			cmd="rm ${cachefile}-tmp"
			eval $cmd

			unset cmd
			unset condition
			unset svnstatus
			unset item_unknow_array
			unset item_commit_array
			unset item_uncache_array
			unset item_cache_array
			continue
		fi
	fi

	condition="$condition$inputvar"

	if [[ "$condition" =~ [[:alnum:]] ]]; then
		cmds=($condition)
		cmd1=${cmds[0]}
		cmd2=${cmds[1]}
		# 第三個引數，是位置
		cmd3=${cmds[2]}

		if [ "$mode" == '1' ]; then
			item_unknow_array=( `func_relative_by_svn_append "$cmd1" "$cmd2" "$cmd3" "unknow" "" ""` )
		elif [ "$mode" == '2' ]; then
			item_commit_array=( `func_relative_by_svn_append "$cmd1" "$cmd2" "$cmd3" "commit" "" ""` )
		elif [ "$mode" == '3' ]; then
			item_uncache_array=( `func_relative_by_svn_append "$cmd1" "$cmd2" "$cmd3" "uncache" "$uncachefile" "$cachefile"` )
		elif [ "$mode" == '4' ]; then
			item_cache_array=( `func_relative_by_svn_append "$cmd1" "$cmd2" "$cmd3" "cache" "$uncachefile" "$cachefile"` )
		fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		unset cmd
		unset condition
		unset svnstatus
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
