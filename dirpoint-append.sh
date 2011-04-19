#!/bin/bash

source "$fast_change_dir_func/dialog.sh"
source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/relativeitem.sh"

dirpoint=$1
# cmd1、2是第一、二個關鍵字
cmd1=$2
cmd2=$3
# 位置，例如e就代表1，或者你也可以輸入1
cmd3=$4

if [ "$dirpoint" != "" ]; then

	item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "dir"` )

	if [ "${#item_array[@]}" -gt 1 ]; then
		# 雖然沒有選到資料夾，不過可以用dialog試著來輔助
		tmpfile="$fast_change_dir_tmp/`whoami`-dirpointappend-dialogselect-$( date +%Y%m%d-%H%M ).txt"
		dialogitems=''
		for echothem in ${item_array[@]}
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
			match=`echo $result | sed 's/___/ /g'`
			relativeitem=$match
		fi
	elif [ "${#item_array[@]}" -eq 1 ]; then 
		relativeitem=${item_array[0]}
	fi
	
	if [[ "$relativeitem" != "" && "$groupname" != "" ]]; then
		echo "$dirpoint,`pwd`/$relativeitem" >> $fast_change_dir_project_config/dirpoint-$groupname.txt
		cat $fast_change_dir_project_config/dirpoint-$groupname.txt
	elif [ "$groupname" == "" ]; then
		echo '[ERROR] groupname is empty, please use GA cmd'
	fi
else
	echo '[ERROR] "dirpoint-arg01" "nextRelativeItem-arg02" "secondCondition-arg03" "Position-arg04"'
fi

unset dirpoint
unset cmd
unset cmd1
unset cmd2
unset cmd3
unset number
unset item_array
unset relativeitem
