#!/bin/bash

# 這支檔案的運作方式，很簡單，
# 先做列表，針對資料夾，並存在陣列，
# 接下來就看你要編號多少的陣列元素，取出來而以。

source "$fast_change_dir/gisanfu-function.sh"

# default ifs value
default_ifs=$' \t\n'

# fix space to effect array result
IFS=$'\012'

dirPosition=$1

if [ "$dirPosition" != "" ]; then
	dirList=(`ls -AFL | grep "/$"`)
	if [ "${#dirList[@]}" -lt 1 ]; then
		func_statusbar 'THERE-IS-NO-DIR'
	else	
		if [ "${dirList[$dirPosition - 1]}" == "" ]; then
			func_statusbar 'THIS-POSITION-IS-NO-DIR'
		else
			cd ${dirList[$dirPosition - 1]}
			# check file count and ls action
			func_checkfilecount
		fi
	fi
else
	func_statusbar 'PLEASE-INPUT-ARG01'
fi

IFS=$default_ifs
