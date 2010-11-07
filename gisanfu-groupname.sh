#!/bin/bash

#
# 這個檔案，是選擇、以及增加專案代碼
#

source 'gisanfu-function.sh'

action=$1
groupname=$2
tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt

if [ "$action" == "select" ]; then
	if [ "$groupname" != "" ]; then
		count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
		if [ "$count" == "0" ]; then
			export groupname=""
			echo "[ERROR] groupname is not exist by $groupname"
		else
			export groupname=$groupname
			echo '[OK] export groupname success'
			# 切換到Root的資料夾，預設是root，這是我建立資料夾link的方式，根目錄名稱叫root
			. /bin/gisanfu-dirpoint.sh root
		fi
	else
		dialogitems=`cat ~/gisanfu-groupname.txt | awk -F"\n" '{ print $1 " \" \" " }' | tr "\n" ' '`
		cmd=$( func_dialog_menu '請選擇專案代碼' 70 "$dialogitems" "$tmpfile" )

		eval $cmd
		result=`cat $tmpfile`

		if [ "$result" == "" ]; then
			func_statusbar '你不選嗎，別忘了要選才能使用專案功能哦'
		else
			export groupname=$result
			echo '[OK] export groupname success'
			# 切換到Root的資料夾，預設是root，這是我建立資料夾link的方式，根目錄名稱叫root
			. /bin/gisanfu-dirpoint.sh root
		fi
	fi
elif [ "$action" == "append" ]; then
	if [ "$groupname" != "" ]; then
		count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
		if [ "$count" == "0" ]; then
			echo $groupname >> ~/gisanfu-groupname.txt
			export groupname=$groupname
			echo '[OK] append and export groupname success'
		else
			echo "[ERROR] groupname is exist by $groupname"
		fi
	else
		echo "[ERROR] please fill groupname field by append action"
	fi
elif [ "$action" == "edit" ]; then
	vim ~/gisanfu-groupname.txt
else
	echo '[ERROR] no support action'
fi
