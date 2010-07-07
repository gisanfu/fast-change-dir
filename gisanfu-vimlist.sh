#!/bin/bash

program=$1

if [ "$program" == "" ]; then
	program="vim -p"
fi

if [ "$groupname" != "" ]; then
	$program `cat ~/gisanfu-vimlist-$groupname.txt | tr "\n" " "`
	func_checkfilecount
else
	echo '[ERROR] groupname is empty, please use GA cmd'
fi
