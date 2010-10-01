#!/bin/bash

color_txtred='\e[0;31m' # Red
color_txtgrn='\e[0;32m' # Green
color_none='\e[0m' # No Color

while [ 1 ];
do
	clear
	echo '選擇指令介面 (ide)'
	echo '================================================='
	echo -e "${color_txtgrn}檔案工具類:${color_none}"
	echo ''
	echo 'a. Operation Item By Keyword (num)'
	echo 'b. Search By File (sear)'
	echo 'c. Searcy By Keyword (gre)'
	echo 'd. File Explorer (nautilus .)'
	echo '================================================='
	echo -e "${color_txtgrn}專案捷徑類:${color_none}"
	echo ''
	echo 'e. Select Project (ga)'
	echo 'f. Select Shortcut (dv)'
	echo '================================================='
	echo -e "${color_txtgrn}檔案操作類:${color_none}"
	echo ''
	echo 'g. Show Groupfile (vff)'
	echo 'h. Vim Groupfile (vfff)'
	echo 'i. Clear Groupfile (vffff)'
	echo '================================================='

	echo -e "請輸入指令編號，或按${color_txtred}q${color_none}離開:"

	read -s -n 1 inputvar

	if [ "$inputvar" == 'q' ]; then
		break
	elif [ "$inputvar" == 'a' ]; then
		num
	elif [ "$inputvar" == 'b' ]; then
		sear
	elif [ "$inputvar" == 'c' ]; then
		gre
	elif [ "$inputvar" == 'd' ]; then
		nautilus .
	elif [ "$inputvar" == 'e' ]; then
		ga
	elif [ "$inputvar" == 'f' ]; then
		dv
	elif [ "$inputvar" == 'g' ]; then
		vff
	elif [ "$inputvar" == 'h' ]; then
		vfff
	elif [ "$inputvar" == 'i' ]; then
		echo '你確定要清空vim暫存群組檔嗎?[nf0,Yj1]'
		read -s -n 1 inputvar
		if [[ "$inputvar" == 'y' || "$inputvar" == 'j' || "$inputvar" == "1" ]]; then
			vffff
			echo '己清空'
			sleep 1
		elif [[ "$inputvar" == 'n' || "$inputvar" == "f" || "$inputvar" == "0" ]]; then
			echo '己取消清空vim暫存群組檔'
			sleep 1
		else
			echo '己取消清空vim暫存群組檔'
			sleep 1
		fi
	fi
done
