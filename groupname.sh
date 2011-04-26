#!/bin/bash

#
# 這個檔案，是選擇、以及增加專案代碼
#

source "$fast_change_dir_func/dialog.sh"

action_arg=$1
groupname_arg=$2
#tmpfile="$fast_change_dir_tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt"

if [ ! -f $fast_change_dir_config/groupname.txt ]; then
	# 如果檔案不存在，就建立文字檔案，以及建立一個預設空白的groupname
	touch $fast_change_dir_config/groupname.txt
	#echo '""' >> $fast_change_dir_config/groupname.txt
fi

if [ "$action_arg" == "select" ]; then
	# 這個變數是存放選擇後，或是match後的結果
	groupname_select=''

	if [ "$groupname_arg" != "" ]; then
		resultarray=(`grep $groupname_arg $fast_change_dir_config/groupname.txt`)
	else
		resultarray=(`cat $fast_change_dir_config/groupname.txt`)
	fi

	# 先處理與判斷，將結果存起來，最後才去處理那個結果
	if [ "${#resultarray[@]}" -gt "1" ]; then
		# 把陣列轉成dialog，以數字來選單
		dialogitems=''
		start=1
		for echothem in ${resultarray[@]}
		do
			dialogitems=" $dialogitems '$start' $echothem "
			start=$(expr $start + 1)
		done
		tmpfile="$fast_change_dir_tmp/`whoami`-groupname-dialogselect-$( date +%Y%m%d-%H%M ).txt"
		cmd=$( func_dialog_menu 'Please select groupname' 100 "$dialogitems" $tmpfile )

		eval $cmd
		result=`cat $tmpfile`

		if [ -f "$tmpfile" ]; then
			rm -rf $tmpfile
		fi

		if [ "$result" != "" ]; then
			groupname_select=${resultarray[$result - 1]}
		else
			echo '[ERROR] groupname no match, or no select'
		fi
	elif [ "${#resultarray[@]}" == "1" ]; then
		groupname_select=${resultarray[0]}
	else
		echo '[ERROR] groupname is not select or not exist!!'
	fi

	if [ "$groupname_select" != '' ]; then
		export groupname=$groupname_select

		if [ -f $fast_change_dir_config/your-project-config-$groupname_select.sh ]; then
			source $fast_change_dir_config/your-project-config-$groupname_select.sh
			fast_change_dir_project_config=$fast_change_dir_your_project_config
		else
			fast_change_dir_project_config=$fast_change_dir_config
		fi

		echo '[OK] export groupname success'
		# 切換到Root的資料夾，預設是root，這是我建立資料夾link的方式，根目錄名稱叫root
		dv root
	fi

	# 在確認一次，如果有選擇，接下來就檢查是否有定義專案設定檔
	#if [ "$groupname" != "" ]; then
	#	if [ -f $fast_change_dir_config/$groupname-your-project-config.sh ]; then
	#		source $fast_change_dir_config/$groupname-your-project-config.sh
	#		fast_change_dir_project_config=$fast_change_dir_your_project_config
	#	else
	#		fast_change_dir_project_config=$fast_change_dir_config
	#	fi
	#fi
elif [ "$action_arg" == "append" ]; then
	if [ "$groupname_arg" != "" ]; then
		count=`grep -ir $groupname_arg $fast_change_dir_config/groupname.txt | wc -l`
		if [ "$count" == "0" ]; then
			echo $groupname_arg >> $fast_change_dir_config/groupname.txt
			export groupname=$groupname_arg
			echo '[OK] append and export groupname success'
		else
			echo "[ERROR] groupname is exist by $groupname_arg"
		fi
	else
		echo "[ERROR] please fill groupname field by append action"
	fi
elif [ "$action_arg" == "edit" ]; then
	vim $fast_change_dir_config/groupname.txt
else
	echo '[ERROR] no support action'
fi
