#!/bin/bash

if [ "$groupname" != "" ]; then
	vim $fast_change_dir_project_config/vimlist-$groupname.txt

	# 詢問使用者，看要不要編輯list
	echo '[WAIT] 預設是編輯暫存檔案群，我指的是vff [y1,n0]'
	read -n 1 inputchar
	if [[ "$inputchar" == 'y' || "$inputchar" == '1' || "$inputchar" == '' ]]; then
		# 如果不加空白引數，會將外面那一層的引數帶進來，這時會造成程式錯誤
		vff ''
	fi
else
	echo '[ERROR] groupname is empty'
fi
