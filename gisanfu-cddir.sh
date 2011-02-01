#!/bin/bash

source "$fast_change_dir/gisanfu-function.sh"
source "$fast_change_dir/gisanfu-function-entonum.sh"
source "$fast_change_dir/gisanfu-function-relativeitem.sh"

# cmd1、2是第一、二個關鍵字
cmd1=$1
cmd2=$2
# 位置，例如e就代表1，或者你也可以輸入1
cmd3=$3

item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "dir"` )

if [ "${#item_array[@]}" -gt 1 ]; then
	# 雖然沒有選到資料夾，不過可以用dialog試著來輔助
	tmpfile=/tmp/`whoami`-cddir-dialogselect-$( date +%Y%m%d-%H%M ).txt
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
		run="cd \"$match\""
	fi
elif [ "${#item_array[@]}" -eq 1 ]; then 
	run="cd \"${item_array[0]}\""
fi

if [ "$run" != '' ]; then
	eval $run
	# check file count and ls action
	func_checkfilecount
fi

unset cmd
unset cmd1
unset cmd2
unset cmd3
unset run
unset number
unset item_array
