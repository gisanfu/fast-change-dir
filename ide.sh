#!/bin/bash

color_txtred='\e[0;31m' # Red
color_txtgrn='\e[0;32m' # Green
color_none='\e[0m' # No Color

while [ 1 ];
do
	clear
	echo '選擇指令介面 (ide)'
	echo '================================================='
	echo "`whoami` || \"$groupname\" || `pwd`"
	echo '================================================='
	echo -e "${color_txtgrn}檔案工具類:${color_none}"
	echo ''
	echo 'a. 英文模式 (abc)'
	echo 'b. 純數字模式 (123)'
	echo 'c. Search By File (sear)'
	echo 'd. Search By Keyword (gre)'
	echo 'e. File Explorer (nautilus .)'
	echo '================================================='
	echo -e "${color_txtgrn}專案類:${color_none}"
	echo ''
	echo 'g. Select Project (ga)'
	echo 'h. Select Shortcut (dv)'
	echo '================================================='
	echo -e "${color_txtgrn}檔案操作類:${color_none}"
	echo ''
	echo 'i. Show Groupfile (vff)'
	echo 'j. Edit Groupfile (vfff)'
	echo 'k. Clear Groupfile (vffff)'
	echo '================================================='
	echo -e "${color_txtgrn}版本控制類:${color_none}"
	echo ''
	echo 's. SVN (svnn)'
	echo 't. GIT (gitt)'
	echo '================================================='

	echo -e "請輸入指令編號，或按${color_txtred}q${color_none}離開:"

	read -s -n 1 inputvar

	if [ "$inputvar" == 'q' ]; then
		break
	elif [ "$inputvar" == 'a' ]; then
		abc	
	elif [ "$inputvar" == 'b' ]; then
		123	
	elif [ "$inputvar" == 'c' ]; then
		sear
	elif [ "$inputvar" == 'd' ]; then
		gre
	elif [ "$inputvar" == 'e' ]; then
		nautilus .
	elif [ "$inputvar" == 'g' ]; then
		ga
	elif [ "$inputvar" == 'h' ]; then
		dv
	elif [ "$inputvar" == 'i' ]; then
		vff
	elif [ "$inputvar" == 'j' ]; then
		vfff
	elif [ "$inputvar" == 'k' ]; then
		vffff
	elif [ "$inputvar" == 's' ]; then
		svnn
	elif [ "$inputvar" == 't' ]; then
		gitt
	fi
done

# 離開後，顯示現在所在資料夾的檔案
clear
ls
