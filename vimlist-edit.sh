#!/bin/bash

if [ "$groupname" != "" ]; then
	vim $fast_change_dir_config/vimlist-$groupname.txt

	# 詢問使用者，看要不要編輯list
	echo '[WAIT] 預設是編輯暫存檔案群，我指的是vff [Y1,n0]'
	read -n 1 inputchar
	if [[ "$inputchar" == 'y' || "$inputchar" == '1' || "$inputchar" == '' ]]; then
		vff
	fi
else
	echo '[ERROR] groupname is empty'
fi
