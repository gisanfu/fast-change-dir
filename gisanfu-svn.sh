#!/bin/bash

# 這個檔案是加上一些常用的SVN指令在裡面

source 'gisanfu-function.sh'

tmpfile=/tmp/gisanfu_svn.log

svnitems=''
#svnitems="$svnitems 'svn status|grep -e ^M -e ^A' '狀態'"
svnitems="$svnitems 'svn status -q' '狀態'"
svnitems="$svnitems 'svn update' '更新'"
svnitems="$svnitems 'svn commit -m fixbug && svn update' '提交'"
svnitems="$svnitems '. /bin/gisanfu-dirpoint.sh root && svn log -v | more && svn update && /bin/gisanfu-svn-edit-revision.sh && cd -' '以版本號編輯檔案'"

cmd=$( func_dialog_menu '請選擇Svn指令' 80 "$svnitems" "$tmpfile" )

eval $cmd
result=`cat $tmpfile`

if [ "$result" == "" ]; then
	func_statusbar '你沒有選擇任何Svn的指令哦'
else
	eval $result
fi
