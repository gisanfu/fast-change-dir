#!/bin/bash

source "$fast_change_dir_func/normal.sh"
source "$fast_change_dir_func/entonum.sh"
source "$fast_change_dir_func/relativeitem.sh"

# cmd1、2是第一、二個關鍵字
cmd1=$1
cmd2=$2
# 位置，例如e就代表1，或者你也可以輸入1
cmd3=$3

item_array=( `func_relative "$cmd1" "$cmd2" "$cmd3" "" "file"` )

if [ "${#item_array[@]}" -gt 1 ]; then
	echo "重覆的檔案數量: 有${#item_array[@]}筆"
	number=1
	for bbb in ${item_array[@]}
	do
		echo "$number. $bbb"
		number=$((number + 1))
	done
elif [ "${#item_array[@]}" -eq 1 ]; then 
	cmd="vim \"${item_array[0]}\""
	eval $cmd
	# check file count and ls action
	func_checkfilecount
fi

unset cmd
unset cmd1
unset cmd2
unset cmd3
unset number
unset item_array
