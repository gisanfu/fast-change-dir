#!/bin/bash

source 'gisanfu-function-entonum.sh'

# 這是複制svn-v3過來修改的，應該流程是有點類似的

# default ifs value 
default_ifs=$' \t\n'

func_hg_cache_controller()
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

	if [ "$modestatus" == 'hg-status-to-uncache' ]; then
		generate_uncache='1'
		# 會清除，是因為是有相依性的
		clear_cache='1'
	elif [ "$modestatus" == 'clear-cache' ]; then
		generate_uncache='1'
		# 會清除，是因為是有相依性的
		clear_cache='1'
	elif [ "$modestatus" == 'clear-uncache' ]; then
		clear_uncache='1'
		clear_cache='1'
	elif [ "$modestatus" == 'clear-all' ]; then
		clear_uncache='1'
		clear_cache='1'
	fi

	if [ "$generate_uncache" == '1' ]; then
		IFS=$'\n'
		declare -a itemList
		declare -a itemListTmp
		declare -i num

		itemListTmp=(`hg status | grep -e '^A' -e '^M' -e '^R'`)

		cmd="rm -rf $uncachefile"
		eval $cmd

		for i in ${itemListTmp[@]}
		do
			handle1=`echo $i | sed 's/ /___/'`
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
		cmd="rm -rf $cachefile"
		eval $cmd
		cmd="touch $cachefile"
		eval $cmd
	fi

	if [ "$clear_uncache" == '1' ]; then
		cmd="rm -rf $uncachefile"
		eval $cmd
		cmd="touch $uncachefile"
		eval $cmd
	fi

}

func_relative_by_hg_append()
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
		itemListTmp=(`hg status | grep -e '^?' -e '^!' | grep -ir $nextRelativeItem`)
	elif [ "$modestatus" == 'commit' ]; then
		itemListTmp=(`hg status | grep -e '^A' -e '^D' | grep -ir $nextRelativeItem`)
	elif [ "$modestatus" == 'uncache' ]; then
		cmd="cat $uncachefile | grep -ir $nextRelativeItem"
		itemListTmp=(`eval $cmd`)
	elif [ "$modestatus" == 'cache' ]; then
		cmd="cat $cachefile | grep -ir $nextRelativeItem"
		itemListTmp=(`eval $cmd`)
	fi

	for i in ${itemListTmp[@]}
	do
		handle1=`echo $i | sed 's/ /___/'`
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
			itemList2Tmp=(`hg status | grep -e '^?' -e '^!' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'commit' ]; then
			itemList2Tmp=(`hg status | grep -e '^A' -e '^D' | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'uncache' ]; then
			itemList2Tmp=(`cat $uncachefile | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		elif [ "$modestatus" == 'cache' ]; then
			itemList2Tmp=(`cat $cachefile | grep -ir $nextRelativeItem | grep -ir $secondCondition`)
		fi

		for i in ${itemList2Tmp[@]}
		do
			handle1=`echo $i | sed 's/ /___/'`
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

# 會寫這類的函式，是因為這個動作可能會被單項，會是多項來這裡進行觸發
func_hg_unknow_mode()
{
	item=$1

	# 不分兩次做，會出現前面少了一個空白，不知道為什麼
	match=`echo $item | sed 's/___/X/'`
	match=`echo $match | sed 's/___/ /g'`

	# 這個變數，存的可能是?、!
	hgstatus=${match:0:1}

	if [ "$hgstatus" == '?' ]; then
		hg add ${match:2}
	elif [ "$hgstatus" == '!' ]; then
		hg remove ${match:2}
	fi
}

func_hg_commit_mode()
{
	item=$1

	# 不分兩次做，會出現前面少了一個空白，不知道為什麼
	match=`echo $item | sed 's/___/X/'`
	match=`echo $match | sed 's/___/ /g'`

	# 這個變數，存的可能是A、D
	hgstatus=${match:0:1}

	if [ "$hgstatus" == 'A' ]; then
		hg revert ${match:2}
	elif [ "$hgstatus" == 'R' ]; then
		hg revert ${match:2}
	fi
}

func_hg_uncache_mode()
{
	item=$1

	# cache的檔名也是用變數控制
	uncachefile=$2
	cachefile=$3

	cmd="grep '$item' $cachefile"
	tmp1=`eval $cmd`

	if [ "$tmp1" == '' ]; then
		cmd="echo '$item' >> $cachefile"
		eval $cmd
	fi

	# 先寫到暫存，然後在回寫回原來的檔案
	cmd="sed '/$item/d' $uncachefile > ${uncachefile}-hg-tmp"
	eval $cmd
	cmd="cp ${uncachefile}-hg-tmp $uncachefile"
	eval $cmd
	cmd="rm -rf ${uncachefile}-hg-tmp"
	eval $cmd
}

func_hg_cache_mode()
{
	item=$1

	# cache的檔名也是用變數控制
	uncachefile=$2
	cachefile=$3

	cmd="grep '$item' $uncachefile"
	tmp1=`eval $cmd`

	if [ "$tmp1" == '' ]; then
		cmd="echo '$item' >> $uncachefile"
		eval $cmd
	fi

	# 先寫到暫存，然後在回寫回原來的檔案
	cmd="sed '/$item/d' $cachefile > ${cachefile}-hg-tmp"
	eval $cmd
	cmd="cp ${cachefile}-hg-tmp $cachefile"
	eval $cmd
	cmd="rm -rf ${cachefile}-hg-tmp"
	eval $cmd
}

unset cmd
unset cmd1
unset cmd2
unset cmd3

# 只有第一次是1，有些只會執行一次，例如help
first='1'

# 當符合某些條件以後，所以動作都要重來，這時需要清除掉某一些變數的內容
clear_var_all=''

# 倒退鍵
# Ctrl + h
backspace=$(echo -e \\b\\c)

# 這是模式，前面的括號是該模式的別名
# 1. [unknow] hg status, filter by untracked, or new file, 其它都沒有哦
# 2. [commit] hg status, filter by added, or deleted, modify一定會在裡面的(我想取commit list)
# 3. [uncache] uncache list
# 4. [cache] cache list
mode='1'

uncachefile='~/gisanfu-hg-uncache.txt'
cachefile='~/gisanfu-hg-cache.txt'

# 清理uncache的同時，也會一並清除cache，因為它們是有相依性的
func_hg_cache_controller "$uncachefile" "$cachefile" "clear-uncache"

while [ 1 ];
do
	clear

	if [[ "$first" == '1' || "$clear_var_all" == '1' ]]; then
		unset cmd
		unset condition
		unset item_unknow_array
		unset item_commit_array
		unset item_uncache_array
		unset item_cache_array
		clear_var_all=''
		first=''
	fi

	echo 'Mercurial(Hg) (關鍵字)'
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
		cmd="hg status | grep -e '^?' -e '^!'"
	elif [ "$mode" == '2' ]; then
		cmd="hg status | grep -e '^A' -e '^M' -e '^R'"
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
		echo ' 智慧選取單項 (;) 分號'
		echo ' 處理多項(*) 星號'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}Hg功能快速鍵:${color_none}"
		echo ' Change Normal Mode (A)'
		echo ' Change Cache Mode (B)'
		echo ' Commit (C)'
		echo ' Delete Cache/Uncache (D)'
		echo ' Push(send!!) (E)'
		echo ' Generate Uncache (G)'
		echo ' Update (U)'
		echo '輸入條件的結構:'
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
	fi

	echo '================================================='

	# 顯示重覆的Hg未知檔案
	if [ "${#item_unknow_array[@]}" -gt 1 ]; then
		echo "重覆的未知Hg檔案數量: ${#item_unknow_array[@]} [*]"
		number=1
		for bbb in ${item_unknow_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_unknow_array[@]}" -eq 1 ]; then 
		echo "未知的Hg檔案有找到一筆: ${item_unknow_array[0]} [;]"
	fi

	# 顯示己經準備送出，而且狀態是新增、與刪除
	if [ "${#item_commit_array[@]}" -gt 1 ]; then
		echo "重覆的準備送出的Hg，狀態為A與R的檔案數量: ${#item_commit_array[@]} [*]"
		number=1
		for bbb in ${item_commit_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_commit_array[@]}" -eq 1 ]; then 
		echo "準備送出的Hg，狀態為A與R的檔案有找到一筆: ${item_commit_array[0]} [;]"
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
		echo "Uncache檔案有找到一筆: ${item_uncache_array[0]} [;]"
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
		echo "Cache檔案有找到一筆: ${item_cache_array[0]} [;]"
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
		clear_var_all='1'
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

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'B' ]; then
		if [ "$mode" == '3' ]; then
			mode='4'
		elif [ "$mode" == '4' ]; then
			mode='3'
		else
			mode='3'
		fi

		clear_var_all='1'
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
				cmd="hg commit -m \"$changelog\" "

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
					#echo '設定Changelog成功，別忘了要選擇送出哦'
					echo '要不要送出(hg push)呢？[Y1,n0]'
					read inputvar3
					if [[ "$inputvar3" == 'n' || "$inputvar3" == "0" ]]; then
						echo '不要送出的話，那就算了！'
					else
						hg push

						if [ "$?" -eq 0 ]; then
							echo '送出成功'
							func_hg_cache_controller "$uncachefile" "$cachefile" "clear-all"
							mode=1
						else
							echo '送出失敗，請自行做檢查'
						fi
					fi
				fi

				echo '按任何鍵繼續...'
				read -n 1
			fi
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'D' ]; then
		if [ "$mode" == '3' ]; then
			func_hg_cache_controller "$uncachefile" "$cachefile" "clear-uncache"
		elif [ "$mode" == '4' ]; then
			func_hg_cache_controller "$uncachefile" "$cachefile" "clear-cache"
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'E' ]; then
		hg push
		if [ "$?" -eq 0 ]; then
			echo '更新本Hg資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'G' ]; then
		# 匯出後，自動跳到模式3，就是Uncache mode
		func_hg_cache_controller "$uncachefile" "$cachefile" "hg-status-to-uncache"
		mode='3'

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'U' ]; then
		hg pull
		hg update

		if [ "$?" -eq 0 ]; then
			echo '更新本HG資料夾成功'
		fi

		echo '按任何鍵繼續...'
		read -n 1

		clear_var_all='1'
		continue
	elif [ "$inputvar" == ';' ]; then
		if [ ${#item_unknow_array[@]} -eq 1 ]; then
			func_hg_unknow_mode "${item_unknow_array[0]}"
			func_hg_cache_controller "$uncachefile" "$cachefile" "hg-status-to-uncache"
			clear_var_all='1'
			continue
		elif [ ${#item_commit_array[@]} -eq 1 ]; then
			func_hg_commit_mode "${item_commit_array[0]}"
			func_hg_cache_controller "$uncachefile" "$cachefile" "hg-status-to-uncache"
			clear_var_all='1'
			continue
		elif [ ${#item_uncache_array[@]} -eq 1 ]; then
			func_hg_uncache_mode "${item_uncache_array[0]}" "$uncachefile" "$cachefile"
			clear_var_all='1'
			continue
		elif [ ${#item_cache_array[@]} -eq 1 ]; then
			func_hg_cache_mode "${item_cache_array[0]}" "$uncachefile" "$cachefile"
			clear_var_all='1'
			continue
		fi
	elif [ "$inputvar" == '*' ]; then
		if [ "${#item_unknow_array[@]}" -gt 1 ]; then
			for bbb in ${item_unknow_array[@]}
			do
				func_hg_unknow_mode "$bbb"
			done
			func_hg_cache_controller "$uncachefile" "$cachefile" "hg-status-to-uncache"
			clear_var_all='1'
			continue
		elif [ "${#item_commit_array[@]}" -gt 1 ]; then
			for bbb in ${item_commit_array[@]}
			do
				func_hg_commit_mode "$bbb"
			done
			func_hg_cache_controller "$uncachefile" "$cachefile" "hg-status-to-uncache"
			clear_var_all='1'
			continue
		elif [ "${#item_uncache_array[@]}" -gt 1 ]; then
			for bbb in ${item_uncache_array[@]}
			do
				func_hg_uncache_mode "$bbb" "$uncachefile" "$cachefile"
			done
			clear_var_all='1'
			continue
		elif [ "${#item_cache_array[@]}" -gt 1 ]; then
			for bbb in ${item_cache_array[@]}
			do
				func_hg_cache_mode "$bbb" "$uncachefile" "$cachefile"
			done
			clear_var_all='1'
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
			item_unknow_array=( `func_relative_by_hg_append "$cmd1" "$cmd2" "$cmd3" "unknow" "" ""` )
		elif [ "$mode" == '2' ]; then
			item_commit_array=( `func_relative_by_hg_append "$cmd1" "$cmd2" "$cmd3" "commit" "" ""` )
		elif [ "$mode" == '3' ]; then
			item_uncache_array=( `func_relative_by_hg_append "$cmd1" "$cmd2" "$cmd3" "uncache" "$uncachefile" "$cachefile"` )
		elif [ "$mode" == '4' ]; then
			item_cache_array=( `func_relative_by_hg_append "$cmd1" "$cmd2" "$cmd3" "cache" "$uncachefile" "$cachefile"` )
		fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		clear_var_all='1'

		# 這裡不用在continue了，因為這裡是最後一行了
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
