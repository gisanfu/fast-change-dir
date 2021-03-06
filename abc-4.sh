#!/bin/bash

source "$fast_change_dir/config/config.sh"
source "$fast_change_dir_config/config.sh"

source "$fast_change_dir_func/dialog.sh"
source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/ignore.sh"
source "$fast_change_dir_func/relativeitem.sh"

# default ifs value 
default_ifs=$' \t\n'

# 在這裡，優先權最高的(我指的是按.優先選擇的項目)
# 是檔案(^D) > 資料夾(^F) > 上一層的檔案(^A) > 上一層的資料夾(^S)

func_dirpoint()
{
	dirpoint=$1

	if [[ "$groupname" != '' && "$dirpoint" != '' ]]; then
		resultarray=(`grep ^$dirpoint[[:alnum:]]*, $fast_change_dir_project_config/dirpoint-$groupname.txt | cut -d, -f1`)
		echo ${resultarray[@]}
	fi
}

func_groupname()
{
	groupname=$1

	resultarray=(`grep $groupname $fast_change_dir_config/groupname.txt`)
	echo ${resultarray[@]}
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

fast_change_dir_switch_list='1'

while [ 1 ];
do
	clear

	fast_change_dir_auto_list_file_enable='0'

	if [[ "$clear_var_all" == '1' || "$needhelp" == '1' ]]; then
		unset condition
		unset inputvar
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset cmd1
		unset cmd2
		unset cmd3
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

		if [ "$fast_change_dir_switch_list" == '1' ]; then
			ignorelist=$(func_getlsignore)
			cmd="ls -AF $ignorelist --color=auto"
			eval $cmd
		elif [ "$fast_change_dir_switch_list" == '2' ]; then
			tree -L 1
		elif [ "$fast_change_dir_switch_list" == '3' ]; then
			tree -L 1 -d
		elif [ "$fast_change_dir_switch_list" == '4' ]; then
			tree -L 2
		elif [ "$fast_change_dir_switch_list" == '5' ]; then
			tree -L 2 -d
		elif [ "$fast_change_dir_switch_list" == '6' ]; then
			ignorelist=$(func_getlsignore)
			cmd="ls -AF $ignorelist --color=never"
			eval $cmd
		else
			ignorelist=$(func_getlsignore)
			cmd="ls -AF $ignorelist --color=auto"
			eval $cmd
		fi


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
		echo ' 將單檔案列入暫存，並使用vim編輯它們 (;) 分號'
		echo ' 只將單檔案列入暫存 (;) 分號'
		echo ' 將多個檔案列入暫存，並使用vim編輯它們 (*)'
		echo ' 只將多個檔案列入暫存 (&)'
		echo ' 切換檔案列表的方式 (T)'
		echo ' 上一層 (,) 逗點'
		echo ' 上一個資料夾 (<) 小於，跟上一層是同一個按鍵'
		echo " 到數字切換資料夾功能 (') 單引號"
		echo ' 我忘了快速鍵了 (H)'
		echo ' 離開 (?)'
		echo -e "${color_txtgrn}即時關鍵字選擇用的快速鍵:${color_none}"
		echo ' 檔案或資料夾建立刪除 (C) New item or Delete'
		echo ' 單項檔案 (F) 大寫F shift+f'
		echo ' 單項資料夾 (D)'
		echo ' 上一層單項檔案 (S)'
		echo ' 上一層單項資料夾 (A)'
		echo -e "${color_txtgrn}只能使用快速鍵來選擇關鍵字所帶出來的項目:${color_none}"
		echo ' 專案捷徑名稱 (L)'
		echo ' 群組名稱 (G)'
		echo ' 搜尋檔案的結果 (Z)'
		echo ' 搜尋資料夾的結果 (N)'
		echo ' 無路徑nopath的結果 (W)'
		echo -e "${color_txtgrn}VimList操作類:${color_none}"
		echo ' 一次10個 (I)'
		echo ' 每次20個 (U)'
		echo ' 利用檔案做索引，進入該檔案所在的資料夾 (O)'
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

	# 不加IFS=012的話，我輸入空格，read variable是讀不到的
	IFS=$'\012'
	read -s -n 1 inputvar
	IFS=$default_ifs

	if [ "$inputvar" == ';' ]; then
		inputvar='F'
	elif [ "$inputvar" == '.' ]; then
		inputvar='D'
	elif [ "$inputvar" == '*' ]; then
		inputvar='FF'
	elif [ "$inputvar" == '&' ]; then
		inputvar='FFF'
	elif [ "$inputvar" == ':' ]; then
		inputvar='FFFF'
	fi

	#if [[ "$inputvar" == ';' || "$inputvar" == '.' ]]; then
	#	# 雖然沒有選到資料夾，不過可以用dialog試著來輔助
	#	tmpfile="$fast_change_dir_tmp/`whoami`-abc4-dialog-select-action-$( date +%Y%m%d-%H%M ).txt"
	#	dialogitems='file "" dir "" parent-file "" parent-dir "" '
	#	cmd=$( func_dialog_menu '您要做什麼動作?' 100 "$dialogitems" $tmpfile )

	#	eval $cmd
	#	result=`cat $tmpfile`

	#	if [ -f "$tmpfile" ]; then
	#		rm -rf $tmpfile
	#	fi

	#	if [ "$result" == "file" ]; then
	#		inputvar='F'
	#	elif [ "$result" == "dir" ]; then
	#		inputvar='D'
	#	elif [ "$result" == "parent-file" ]; then
	#		inputvar='S'
	#	elif [ "$result" == "parent-dir" ]; then
	#		inputvar='A'
	#	fi
	#fi

	if [ "$inputvar" == '?' ]; then
		# 離開
		clear
		fast_change_dir_auto_list_file_enable='1'

		unset condition
		unset inputvar
		unset item_file_array
		unset item_dir_array
		unset item_parent_file_array
		unset item_parent_dir_array
		unset item_dirpoint_array
		unset item_groupname_array
		unset cmd1
		unset cmd2
		unset cmd3
		clear_var_all=''

		break
	elif [ "$inputvar" == '/' ]; then
		# 重新讀取設定檔
		source "$fast_change_dir_config/config.sh"

		# 砍掉relativeitem cache的檔案
		rm -rf $fast_change_dir_tmp/`whoami`-relativeitem-cache-*

		clear_var_all='1'
		continue
	elif [ "$inputvar" == ',' ]; then
		cd ..	
		clear_var_all='1'
		continue
	elif [ "$inputvar" == '<' ]; then
		cd -
		clear_var_all='1'
		continue
	# 想拉一個檔案進來，接下來會做vff的動作
	elif [ "$inputvar" == 'F' ]; then
		if [ "$groupname" != '' ]; then
			run="vf \"$cmd1\" \"$cmd2\" \"$cmd3\""
		else
			run="v \"$cmd1\" \"$cmd2\" \"$cmd3\""
		fi

		eval $run

		clear_var_all='1'
		continue
	# 想拉一個檔案進來，但是不啟用vff的狀況
	elif [ "$inputvar" == 'FFFF' ]; then
		if [ "$groupname" != '' ]; then
			run="vf \"$cmd1\" \"$cmd2\" \"$cmd3\" 0"
		else
			run="v \"$cmd1\" \"$cmd2\" \"$cmd3\" 0"
		fi

		eval $run

		clear_var_all='1'
		continue
	# 多選功能在使用的，只支援本層
	elif [ "$inputvar" == 'FF' ]; then
		if [ "$groupname" != '' ]; then
			run="vf \"$cmd1\" \"$cmd2\" \"$cmd3\" 2"
		else
			run="v \"$cmd1\" \"$cmd2\" \"$cmd3\" 2"
		fi

		eval $run

		clear_var_all='1'
		continue
	# 多選功能在使用的，只支援本層(不啟動vff)
	elif [ "$inputvar" == 'FFF' ]; then
		if [ "$groupname" != '' ]; then
			run="vf \"$cmd1\" \"$cmd2\" \"$cmd3\" 3"
		else
			run="v \"$cmd1\" \"$cmd2\" \"$cmd3\" 3"
		fi

		eval $run

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'D' ]; then
		run="d \"$cmd1\" \"$cmd2\" \"$cmd3\""
		eval $run

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'S' ]; then
		if [ "$groupname" != '' ]; then
			run="cd .. && vf \"$cmd1\" \"$cmd2\" \"$cmd3\""
		else
			run="cd .. && v \"$cmd1\" \"$cmd2\" \"$cmd3\""
		fi

		eval $run
		cd -

		clear_var_all='1'
		continue
	elif [[ "$inputvar" == 'A' ]]; then
		run="g \"$cmd1\" \"$cmd2\" \"$cmd3\""
		eval $run

		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'L' ]; then
		run="dv \"$cmd1\""
		eval $run
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'G' ]; then
		run="ga \"$cmd1\""
		eval $run
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'I' ]; then
		vff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'U' ]; then
		vfffff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'O' ]; then
		d2ff
		clear_var_all='1'
		continue
	elif [ "$inputvar" == 'T' ]; then
		array=(ls Tree顯示全部 Tree只顯示資料夾 Tree顯示全部2層 Tree只顯示資料夾2層 ls無顏色)
		dialogitems=''
		start=1
		for echothem in ${array[@]}
		do
			dialogitems=" $dialogitems '$start' $echothem "
			start=$(expr $start + 1)
		done
		tmpfile="$fast_change_dir_tmp/`whoami`-abc4T-dialogselect-$( date +%Y%m%d-%H%M ).txt"
		cmd2=$( func_dialog_menu '選擇檔案列表的方式 ' 100 "$dialogitems" $tmpfile )

		eval $cmd2
		result=`cat $tmpfile`

		if [ -f "$tmpfile" ]; then
			rm -rf $tmpfile
		fi

		if [ "$result" != "" ]; then
			fast_change_dir_switch_list=$result
		fi

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
		$fast_change_dir_bin/cmd-refresh-firefox.sh switchonly
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
	# [W] Nopath 簡稱無路徑
	elif [ "$inputvar" == 'W' ]; then
		match=`echo ${item_nopath_array[0]} | sed 's/___/ /g'`
		run="wv \"$match\""
		eval $run
		clear_var_all='1'
		continue
	# [C] Create
	elif [ "$inputvar" == 'C' ]; then
		# 如果沒有輸入關鍵字，那就用dialog來詢問使用者
		# 這時是可以輸入大寫的檔名，或是資料夾名稱
		if [ "$condition" == '' ]; then
			tmpfile="$fast_change_dir_tmp/`whoami`-abc3-filemanage-$( date +%Y%m%d-%H%M ).txt"
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

	elif [ "$condition" == '' ]; then
		# 會符合這裡的條件，是使用Ctrl + H 倒退鍵，把字元都砍光了以後會發生的狀況
		clear_var_all='1'
		continue
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
