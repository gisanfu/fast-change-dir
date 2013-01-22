#!/bin/bash

source "$fast_change_dir_func/normal.sh"

program2="vim -p $fast_change_dir_project_config/vimlist-$groupname.txt"

cmdlist="cat $fast_change_dir_project_config/vimlist-$groupname.txt"

# 先把一些己知的東西先ignore掉，例如壓縮檔
cmdlist="$cmdlist | grep -v .tar.gz | grep -v .zip | grep -v .png | grep -v .gif | grep -v .jpeg | grep -v .jpg"

# 這是多行文字檔內容，變成以空格分格成字串的步驟
cmdlist2='| tr "\n" " "'
cmdlist="$cmdlist $cmdlist2"
cmdlist_result=`eval $cmdlist`
cmd="$program2 $cmdlist_result"

if [ "$cmd" != '' ]; then
	eval $cmd
fi
func_checkfilecount

unset cmd
