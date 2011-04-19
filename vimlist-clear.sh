#!/bin/bash

if [ "$groupname" != '' ]; then
	echo '你確定要清空vim暫存群組檔嗎?[Y1, n0]'
	read -s -n 1 inputvar
	if [[ "$inputvar" == 'n' || "$inputvar" == "0" ]]; then
		echo '己取消清空vim暫存群組檔'
		sleep 1
	else
		rm $fast_change_dir_project_config/vimlist-$groupname.txt
		touch $fast_change_dir_project_config/vimlist-$groupname.txt
		echo '己清空'
		sleep 1
	fi
fi
