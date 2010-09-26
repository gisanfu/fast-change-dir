#!/bin/bash

source 'gisanfu-function.sh'

program=$1

if [ "$program" == "" ]; then
	program="vim -p"
fi

if [ "$groupname" != "" ]; then
	cmdlist=`cat ~/gisanfu-vimlist-$groupname.txt | tr "\n" " "`
	cmd="$program $cmdlist"
	eval $cmd
	func_checkfilecount
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi
