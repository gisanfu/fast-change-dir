#!/bin/bash

# 這個檔案是加上一些常用的SVN指令在裡面

source 'gisanfu-function.sh'

tmpfile=/tmp/gisanfu_svn.log

svnitems="'svn status|grep -e ^M -e ^A' '狀態' 'svn update' '更新' 'svn commit -m fixbug' '提交'"

cmd=$( func_dialog_menu '請選擇Svn指令' 70 "$svnitems" "$tmpfile" )

eval $cmd
result=`cat $tmpfile`

if [ "$result" == "" ]; then
	func_statusbar '你沒有選擇任何Svn的指令哦'
else
	eval $result
fi
