#!/bin/bash

# 這支檔案，碰到ggg.txt，就會查不到，不知道是什麼問題

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/relativeitem.sh"

# cmd1、2是第一、二個關鍵字
cmd1=$1
cmd2=$2
# 位置，例如e就代表1，或者你也可以輸入1
cmd3=$3

item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "file"` )

relativeitem=''
if [ "${#item_array[@]}" -gt 1 ]; then
	tmpfile="$fast_change_dir_tmp/`whoami`-vf-dialog-select-only-file-$( date +%Y%m%d-%H%M ).txt"
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
		relativeitem="$result"
	fi

	#echo "重覆的檔案數量: 有${#item_array[@]}筆"
	#number=1
	#for bbb in ${item_array[@]}
	#do
	#	echo "$number. $bbb"
	#	number=$((number + 1))
	#done
elif [ "${#item_array[@]}" -eq 1 ]; then 
	relativeitem="\"${item_array[0]}\""
	#cmd="vim \"${item_array[0]}\""
	#eval $cmd
	# check file count and ls action
	func_checkfilecount
fi

if [ "$relativeitem" != '' ]; then
	vim $relativeitem
fi

unset cmd
unset cmd1
unset cmd2
unset cmd3
unset item_array
