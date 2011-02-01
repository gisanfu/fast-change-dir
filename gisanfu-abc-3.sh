#!/bin/bash

source "$fast_change_dir/gisanfu-config.sh"
source ~/gisanfu-config.sh

source "$fast_change_dir/gisanfu-function.sh"
source "$fast_change_dir/gisanfu-function-entonum.sh"
source "$fast_change_dir/gisanfu-function-relativeitem.sh"

# default ifs value 
default_ifs=$' \t\n'

# 在這裡，優先權最高的(我指的是按.優先選擇的項目)
# 是檔案(^D) > 資料夾(^F) > 上一層的檔案(^A) > 上一層的資料夾(^S)

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

# 會去搜尋bash_history裡面的字串
func_search_bash_history()
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

	if [ ! -f "~/.bash_history" ]; then
		touch ~/.bash_history
	fi

	if [ "$keyword" != '' ]; then
		cmd="cat ~/.bash_history | grep $keyword"
		if [ "$second" != '' ]; then
			cmd="$cmd | grep $second"
		fi

		# 因為bash_history檔裡面，可能會有很多重覆的指令，所以要把它們濾掉
		cmd="$cmd | sort -u"

		num=0
		IFS=$'\n'
		resultarraytmp=(`eval $cmd`)
		for i in ${resultarraytmp[@]}
		do
			# 為了要解決空白的問題
			resultarray[$num]=`echo $i|sed 's/ /___/g'`
			num=$num+1
		done
		IFS=$default_ifs
		num=0

		if [ "${#resultarray[@]}" -gt 0 ]; then
			if [ "$newposition" == '' ]; then
				echo ${resultarray[@]}
			else
				# 先把含空格的文字，轉成陣列
				aaa=(${resultarray[@]})
				# 然後在指定位置輸出
				echo ${aaa[$newposition]}
			fi
		fi
	fi
}

# 會去搜尋home裡面的gisanfu-ssh.txt檔案內容
# 如果有找到，就會用ssh連線過去
# 檔案內容如下:
# servername1
# servername2
# ...
func_ssh()
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

	if [ ! -f "~/gisanfu-ssh.txt" ]; then
		touch ~/gisanfu-ssh.txt
	fi

	if [ "$keyword" != '' ]; then
		cmd="cat ~/gisanfu-ssh.txt | grep $keyword"
		if [ "$second" != '' ]; then
			cmd="$cmd | grep $second"
		fi

		num=0
		IFS=$'\n'
		resultarraytmp=(`eval $cmd`)
		for i in ${resultarraytmp[@]}
		do
			# 為了要解決空白的問題
			resultarray[$num]=`echo $i|sed 's/ /___/g'`
			num=$num+1
		done
		IFS=$default_ifs
		num=0

		if [ "${#resultarray[@]}" -gt 0 ]; then
			if [ "$newposition" == '' ]; then
				echo ${resultarray[@]}
			else
				# 先把含空格的文字，轉成陣列
				aaa=(${resultarray[@]})
				# 然後在指定位置輸出
				echo ${aaa[$newposition]}
			fi
		fi
	fi
}

# 呼叫這個函式的前面，別忘了要加上至少3個字母的判斷式
func_search()
{
	keyword=$1
	second=$2
	position=$3

	# 可能是file, or dir
	itemtype=$4

	declare -a resultarray
	declare -a resultarraytmp

	# 預設的find指令搜尋的對像，我設定為檔案
	findtype='f'

	# 先把英文轉成數字，如果這個欄位有資料的話
	position=( `func_entonum "$position"` )

	if [ "$position" != '' ]; then
		newposition=$(($position - 1))
	fi

	if [ "$itemtype" == '' ]; then
		itemtype='file'
	fi

	if [ "$itemtype" == 'file' ]; then
		findtype='f'
	elif [ "$itemtype" == 'dir' ]; then
		findtype='d'
	fi

	if [ "$keyword" != '' ]; then
		if [ "$groupname" != '' ]; then
			# 先取得root資料夾位置
			dirpoint_roots=(`cat ~/gisanfu-dirpoint-$groupname.txt | grep ^root | head -n 1 | tr "," " "`)
			path=${dirpoint_roots[1]}
		else
			path='.'
		fi

		cmd="find $path -iname \*$keyword\* -type $findtype"

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

# 呼叫這個函式的前面，別忘了要加上至少3個字母的判斷式
func_search_google()
{
	keyword=$1
	#second=$2
	position=$2

	# 先把英文轉成數字，如果這個欄位有資料的話
	position=( `func_entonum "$position"` )

	filename="/tmp/gisanfu-abc3-google-search-`whoami`.txt"

	if [ "$keyword" != '' ]; then
		cmd="perl $fast_change_dir/gisanfu-google-search.pl $keyword"

		#if [ "$second" != '' ]; then
		#	cmd="$cmd $second"
		#fi

		cmd="$cmd > $filename"
		eval $cmd

		if [ "$position" -gt 0 ]; then
			cmd2="sed -n $(($position*3+$position-1))p $filename"
			eval $cmd2
		fi

	fi
}

unset cmd1
unset cmd2
unset cmd3

# 當符合某些條件以後，所以動作都要重來，這時需要清除掉某一些變數的內容
clear_var_all=''

# 倒退鍵
backspace=$(echo -e \\b\\c)

color_txtgrn='\e[0;32m' # Green
color_txtred='\e[0;31m' # Red
color_none='\e[0m' # No Color

while [ 1 ];
do
	clear

	if [[ "$clear_var_all" == '1' || "$needhelp" == '1' ]]; then
		unset condition
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset item_search_file_array
		unset item_search_dir_array
		unset item_ssh_array
		unset item_search_bash_history_array
		unset item_search_google_string
		unset good_select
		unset good_array
		rm -rf /tmp/gisanfu-abc3-google-search-`whoami`.txt
		clear_var_all=''
	fi

	if [ "$needhelp" == '1' ]; then
		echo '即時切換資料夾 (關鍵字)'
		echo '================================================='
	fi


	# 如果要看HELP，應該就暫時把其它東西hide起來
	if [ "$needhelp" != '1' ]; then
		echo "`whoami` || \"$groupname\" || `pwd`"
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
	fi

	if [ "$needhelp" == '1' ]; then
		echo '================================================='
		echo -e "${color_txtgrn}基本快速鍵:${color_none}"
		echo ' 倒退鍵 (Ctrl + H)'
		echo ' 重新輸入條件 (/)'
		echo ' 智慧選取單項 (;) 分號'
		echo ' 上一層 (,) 逗點'
		echo " 到數字切換資料夾功能 (') 單引號"
		echo ' 我忘了快速鍵了 (H)'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}即時關鍵字選擇用的快速鍵:${color_none}"
		echo ' 檔案或資料夾建立刪除 (C) New item or Delete'
		echo ' 單項檔案 (F) 大寫F shift+f'
		echo ' 單項資料夾 (D)'
		echo ' 上一層單項檔案 (S)'
		echo ' 上一層單項資料夾 (A)'
		echo ' 專案捷徑名稱 (L)'
		echo ' 群組名稱 (G)'
		echo ' 搜尋檔案的結果 (Z)'
		echo ' 搜尋資料夾的結果 (N)'
		echo -e "${color_txtgrn}VimList操作類:${color_none}"
		echo ' Do It! (I)'
		echo ' Modify (J)'
		echo ' Clear (K)'
		echo -e "${color_txtgrn}搜尋引擎類:${color_none}"
		echo ' Google Search (B)'
		echo -e "${color_txtgrn}版本控制群:${color_none}"
		echo ' Versions (V)'
		echo -e "${color_txtgrn}桌面互動類:${color_none}"
		echo ' Nautilus File Explorer (E)'
		echo ' Firefox Show (R)'
		echo -e "${color_txtgrn}系統類:${color_none}"
		echo ' Grep以關鍵字去搜尋檔案 (M)'
		echo ' SSH (P)'
		echo ' Sudo Root (Y)'
		echo ' History Bash (U)'
		echo ' 離開EXIT (X)(Q)'
		echo -e "${color_txtgrn}輸入條件的結構:${color_none}"
		echo ' "關鍵字1" [space] "關鍵字2" [space] "英文位置ersfwlcbko(1234567890)"'
		if [ "$needhelp" == '1' ]; then
			echo -e "${color_txtred}你記得快速鍵了嗎？記得的話，按任何鍵繼續...${color_none}"
			read -s -n 1
			unset needhelp
			clear_var_all='1'
			continue
		fi
	fi

	if [ "$condition" != '' ]; then
		echo '================================================='
		echo '檔案或資料夾建立刪除 [C]'
	fi

	if [ "${#item_file_array[@]}" -gt 0 ]; then
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

	if [ "${#item_dir_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆資料夾
	if [ "${#item_dir_array[@]}" -gt 1 ]; then
		echo "重覆的資料夾數量[D]: 有${#item_dir_array[@]}筆"
		number=1
		for bbb in ${item_dir_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦[D]: ${item_dir_array[0]}"
	fi

	if [ "${#item_parent_file_array[@]}" -gt 0 ]; then
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

	if [ "${#item_parent_dir_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆資料夾(上一層)
	if [ "${#item_parent_dir_array[@]}" -gt 1 ]; then
		echo "重覆的資料夾數量(上一層)[A]: 有${#item_parent_dir_array[@]}筆"
		number=1
		for bbb in ${item_parent_dir_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_parent_dir_array[@]}" -eq 1 ]; then 
		echo "資料夾有找到一筆哦(上一層)[A]: ${item_parent_dir_array[0]}"
	fi

	if [ "${#item_dirpoint_array[@]}" -gt 0 ]; then
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

	if [ "${#item_groupname_array[@]}" -gt 0 ]; then
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

	if [ "${#item_search_file_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆的搜尋檔案結果項目
	if [ "${#item_search_file_array[@]}" -gt 1 ]; then
		echo "重覆的搜尋檔案結果(有多項的功能)[Z]: 有${#item_search_file_array[@]}筆"
		number=1
		for bbb in ${item_search_file_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_search_file_array[@]}" -eq 1 ]; then 
		echo "搜尋檔案的結果有找到一筆哦[Z]: ${item_search_file_array[0]}"
	fi

	if [ "${#item_search_dir_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆的搜尋資料夾結果項目
	if [ "${#item_search_dir_array[@]}" -gt 1 ]; then
		echo "重覆的搜尋資料夾結果: 有${#item_search_dir_array[@]}筆"
		number=1
		for bbb in ${item_search_dir_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_search_dir_array[@]}" -eq 1 ]; then 
		echo "搜尋資料夾的結果有找到一筆哦[N]: ${item_search_dir_array[0]}"
	fi

	if [ "${#item_ssh_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆的SSH清單
	if [ "${#item_ssh_array[@]}" -gt 1 ]; then
		echo "重覆的SSH清單列表: 有${#item_ssh_array[@]}筆"
		number=1
		for bbb in ${item_ssh_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_ssh_array[@]}" -eq 1 ]; then 
		echo "SSH目標有找到一筆哦[P]: ${item_ssh_array[0]}"
	fi

	if [ "${#item_search_bash_history_array[@]}" -gt 0 ]; then
		echo '================================================='
	fi

	# 顯示重覆的Bash History搜尋結果
	if [ "${#item_search_bash_history_array[@]}" -gt 1 ]; then
		echo "重覆的Bash History列表: 有${#item_search_bash_history_array[@]}筆"
		number=1
		for bbb in ${item_search_bash_history_array[@]}
		do
			echo "$number. $bbb"
			number=$((number + 1))
		done
	elif [ "${#item_search_bash_history_array[@]}" -eq 1 ]; then 
		echo "Bash History有找到一筆哦[U]: ${item_search_bash_history_array[0]}"
	fi

	# 顯示重覆的Google搜尋結果
	if [ "$item_search_google_string" == '' ]; then
		if [ -f "/tmp/gisanfu-abc3-google-search-`whoami`.txt" ]; then
			echo '================================================='
			echo "Google有找到資料哦:"
			cat "/tmp/gisanfu-abc3-google-search-`whoami`.txt"
		fi
	else
		echo '================================================='
		echo "Google有找到一筆哦[B]: $item_search_google_string"
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
		# 重新讀取設定檔
		source ~/gisanfu-config.sh

		clear_var_all='1'
		continue
	elif [ "$inputvar" == ',' ]; then
		cd ..	
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == ';' || "$inputvar" == '.' ]]; then

		# 這裡改成強制一定要有一項被選中才能走到這裡面
		# 另外，也改成僅支援檔案和資料夾的功能才能使用
		if [ "$good_select" == '' ]; then
			clear_var_all='1'
			continue
		fi

		# 這樣子做，就不用問我要append還是不要
		if [ "$inputvar" == ';' ]; then
			isvff='1'
		elif [ "$inputvar" == '.' ]; then
			isvff='0'
		else
			isvff=''
		fi


		run=''
		match=`echo ${good_array[0]} | sed 's/___/ /g'`

		case $good_select in
			1 )
				if [ "$groupname" != '' ]; then
					run="vf \"$match\" \"\" $isvff"
				else
					run="vim \"$match\""
				fi
				;;
			2 )
				run="cd \"$match\""
				;;
			3 )
				if [ "$groupname" != '' ]; then
					run="cd .. && vf \"$match\" \"\" $isvff"
				else
					run="vim ../\"$match\""
				fi
				;;
			4 )
				match=`echo ${item_parent_dir_array[0]} | sed 's/___/ /g'`
				run="cd ../\"$match\""
				;;
		esac

		if [ "$run" != '' ]; then
			eval $run
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'F' ]; then
		run=''
		if [ "${#item_file_array[@]}" -eq 1 ]; then
			match=`echo ${item_file_array[0]} | sed 's/___/ /g'`
			if [ "$groupname" != '' ]; then
				run="vf \"$match\""
			else
				run="vim \"$match\""
			fi
		elif [ "${#item_file_array[@]}" -gt 1 ]; then
			run=". $fast_change_dir/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_file_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"$match\""
			done
		else
			echo -e "${color_txtred}[ERROR]${color_none} 沒有任何檔案被選擇，請按Enter鍵離開..."
			read -s drop_variable_aabbcc
		fi

		if [ "$run" != '' ]; then
			eval $run
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'D' ]; then
		run=''
		if [ "${#item_dir_array[@]}" == 1 ]; then
			match=`echo ${item_dir_array[0]} | sed 's/___/ /g'`
			run="cd \"$match\""
		else
			# 雖然沒有選到資料夾，不過可以用dialog試著來輔助
			tmpfile=/tmp/`whoami`-abc3-goodselect-$( date +%Y%m%d-%H%M ).txt
			dialogitems=''
			for echothem in ${item_dir_array[@]}
			do
				dialogitems=" $dialogitems $echothem '' "
			done
			cmd=$( func_dialog_menu '請從裡面挑一項你所要的' 100 "$dialogitems" $tmpfile )

			eval $cmd
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi

			if [ "$result" != "" ]; then
				item_dir_array=$result
				match=`echo $result | sed 's/___/ /g'`
				run="cd \"$match\""
			else
				clear_var_all='1'
				continue
			fi
		fi

		if [ "$run" != '' ]; then
			eval $run
		fi

		clear_var_all='1'
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
			run=". $fast_change_dir/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_parent_file_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"../$match\""
			done
		fi
		eval $run
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'A' ]]; then
		if [ "${#item_parent_dir_array[@]}" == 1 ]; then
			match=`echo ${item_parent_dir_array[0]} | sed 's/___/ /g'`
			run="g \"$match\""
		else
			# 雖然沒有選到資料夾，不過可以用dialog試著來輔助
			tmpfile=/tmp/`whoami`-abc3-goodselect-$( date +%Y%m%d-%H%M ).txt
			dialogitems=''
			for echothem in ${item_parent_dir_array[@]}
			do
				dialogitems=" $dialogitems $echothem '' "
			done
			cmd=$( func_dialog_menu '請從裡面挑一項你所要的' 100 "$dialogitems" $tmpfile )

			eval $cmd
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi

			if [ "$result" != "" ]; then
				item_dir_array=$result
				match=`echo $result | sed 's/___/ /g'`
				run="g \"$match\""
			else
				clear_var_all='1'
				continue
			fi
		fi

		if [ "$run" != '' ]; then
			eval $run
		fi

		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'L' && "${#item_dirpoint_array[@]}" == 1 ]]; then
		match=`echo ${item_dirpoint_array[0]} | sed 's/___/ /g'`
		run="dv \"$match\""
		eval $run
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'G' && "${#item_groupname_array[@]}" == 1 ]]; then
		match=`echo ${item_groupname_array[0]} | sed 's/___/ /g'`
		run="ga \"$match\""
		eval $run
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'Z' ]; then
		if [ "${#item_search_file_array[@]}" -eq 1 ]; then
			match=`echo ${item_search_file_array[0]} | sed 's/___/ /g'`
			if [ "${match:0:1}" == '.' ]; then
				run=". $fast_change_dir/gisanfu-vimlist-append-with-path.sh \"\" \"$match\""
			else
				run=". $fast_change_dir/gisanfu-vimlist-append-with-path.sh \"$match\" \"\""
			fi
		elif [ "${#item_search_file_array[@]}" -gt 1 ]; then
			run=". $fast_change_dir/gisanfu-vimlist-append-files.sh "
			for bbb in ${item_search_file_array[@]}
			do
				match=`echo $bbb | sed 's/___/ /g'`
				run="$run \"$match\""
			done
		fi
		eval $run
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'N' && "${#item_search_dir_array[@]}" == 1 ]]; then
		match=`echo ${item_search_dir_array[0]} | sed 's/___/ /g'`
		run="cd \"$match\""
		eval $run
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'P' && "${#item_ssh_array[@]}" == 1 ]]; then
		match=`echo ${item_ssh_array[0]} | sed 's/___/ /g'`
		run="ssh \"$match\""
		eval $run
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'U' && "${#item_search_bash_history_array[@]}" == 1 ]]; then
		match=`echo ${item_search_bash_history_array[0]} | sed 's/___/ /g'`
		#run="\"$match\""
		#eval $run
		eval "$match"
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'B' && "$item_search_google_string" != '' ]]; then
		run="w3m \"$item_search_google_string\""
		eval $run
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'I' ]; then
		vff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'J' ]; then
		vfff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'K' ]; then
		vffff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'V' ]; then
		# 先檢查現在的資料夾裡，是否含有版本控制的隱藏資料夾在內
		if [ -d '.git' ]; then
			gitt
			clear_var_all='1'
			continue
		elif [ -d '.svn' ]; then
			svnn
			clear_var_all='1'
			continue
		elif [ -d '.hg' ]; then
			hgg
			clear_var_all='1'
			continue
		fi

		echo "請輸入版本控制名稱的前綴，或按Enter離開"
		echo "Git (gG)"
		echo "Svn (sS)"
		echo "Hg (hH)"
		read -s -n 1 inputvar2

		if [[ "$inputvar2" == 'G' || "$inputvar2" == 'g' ]]; then
			gitt
		elif [[ "$inputvar2" == 'S' || "$inputvar2" == 's' ]]; then
			svnn
		elif [[ "$inputvar2" == 'H' || "$inputvar2" == 'h' ]]; then
			hgg
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'E' ]; then
		nautilus .
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'R' ]; then
		$fast_change_dir/gisanfu-cmd-refresh-firefox.sh switchonly
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'M' ]; then
		gre
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'Y' ]; then
		sudo su -
		clear_var_all='1'
		continue
	# [C] Create
	elif [ "$inputvar" == 'C' ]; then
		# 如果沒有輸入關鍵字，那就用dialog來詢問使用者
		# 這時是可以輸入大寫的檔名，或是資料夾名稱
		if [ "$condition" == '' ]; then
			tmpfile=/tmp/`whoami`-abc3-filemanage-$( date +%Y%m%d-%H%M ).txt
			cmd=$( func_dialog_input '請輸入檔案或資料夾名稱' "" 70 "$tmpfile" )

			eval $cmd
			result=`cat $tmpfile`

			if [ "$result" == "" ]; then
				clear_var_all='1'
				continue
			else
				condition="$result"
			fi
		fi

		echo "請選擇你要做的動作:"
		echo "File Touch(Ff)"
		echo "Create Directory And Goto DIR (Dd)"
		read -s -n 1 inputvar2

		if [[ "$inputvar2" == 'F' || "$inputvar2" == 'f' ]]; then
			if [[ -f "$condition" || -d "$condition" ]]; then
				echo -e "${color_txtred}[ERROR]${color_none} 不能建立空白檔案，因為有同名的檔案或資料夾己經存在，請按任意鍵離開..."
				read -s -n 1
			else
				touch $condition
				vf $condition
			fi
		elif [[ "$inputvar2" == 'D' || "$inputvar2" == 'd' ]]; then
			mkdir $condition
			if [ "$?" -eq 0 ]; then
				d $condition
				sleep 2
			else
				echo -e "${color_txtred}[ERROR]${color_none} 建立資料夾失敗，應該是有同名的檔案或資料夾己經存在，請按任意鍵離開..."
				read -s -n 1
			fi
		fi

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'H' ]; then
		needhelp='1'
		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'X' || "$inputvar" == 'Q' ]]; then
		exit
	# 我也不知道，為什麼只能用Ctrl + H 來觸發倒退鍵的事件
	elif [ "$inputvar" == $backspace ]; then
		condition="${condition:0:(${#condition} - 1)}"
		inputvar=''
	elif [ "$inputvar" == "'" ]; then
		abc123
		clear_var_all='1'
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

		# 決定誰是最佳人選，當你按了;分號或是.點
		if [ ${#item_file_array[@]} -eq 1 ]; then
			good_select=1
			good_array=${item_file_array[@]}
		elif [ ${#item_dir_array[@]} -eq 1 ]; then
			good_select=2
			good_array=${item_dir_array[@]}
		fi

		if [ "$gisanfu_config_parent_enable" == '1' ]; then
			item_parent_file_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "../" "file"` )
			item_parent_dir_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "../" "dir"` )

			# 決定誰是最佳人選，當你按了;分號或是.點
			if [ ${#item_parent_file_array[@]} -eq 1 ]; then
				good_select=3
				good_array=${item_parent_file_array[@]}
			elif [ ${#item_parent_dir_array[@]} -eq 1 ]; then
				good_select=4
				good_array=${item_parent_dir_array[@]}
			fi
		fi

		item_ssh_array=( `func_ssh "$cmd1" "$cmd2" "$cmd3"` )

		if [ "$gisanfu_config_bashhistorysearch_enable" == '1' ]; then
			if [ "${#cmd1}" -gt 3 ]; then
				item_search_bash_history_array=( `func_search_bash_history "$cmd1" "$cmd2" "$cmd3"` )
			fi
		fi

		# 長度大於3的關鍵字才能做搜尋的動作
		if [[ "${#cmd1}" -gt 3 && "$groupname" != 'home' && "$groupname" != '' ]]; then
			if [ "$gisanfu_config_searchfile_enable" == '1' ]; then
				item_search_file_array=( `func_search "$cmd1" "$cmd2" "$cmd3" "file" ` )
			fi

			if [ "$gisanfu_config_searchdir_enable" == '1' ]; then
				item_search_dir_array=( `func_search "$cmd1" "$cmd2" "$cmd3" "dir" ` )
			fi
		fi

		# 有些功能，只要看到第2個引數就會失效
		if [ "$cmd2" == '' ]; then
			item_dirpoint_array=( `func_dirpoint "$cmd1"` )
			item_groupname_array=( `func_groupname "$cmd1"` )
		else
			unset item_dirpoint_array
			unset item_groupname_array
		fi

		# 這個功能不錯用，但是會拖累整個操作速度
		if [ "$gisanfu_config_googlesearch_enable" == '1' ]; then
			if [[ "${#cmd1}" -gt 3 && "${#cmd2}" -le 2 ]]; then
				item_search_google_string=`func_search_google "$cmd1" "$cmd2" `
			else
				unset item_search_google_string
				rm /tmp/gisanfu-abc3-google-search-`whoami`.txt
			fi
		fi
	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		clear_var_all='1'
		continue
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
