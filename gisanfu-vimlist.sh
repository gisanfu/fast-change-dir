#!/bin/bash

program=$1

if [ "$program" == "" ]; then
	program="vim -p"
fi

if [ "$groupname" != "" ]; then
	$program `cat ~/gisanfu-vimlist-$groupname.txt | tr "\n" " "`
else
	echo '[ERROR] groupname is empty'
fi
