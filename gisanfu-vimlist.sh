#!/bin/bash


if [ "$groupname" != "" ]; then
	vim -p `cat ~/gisanfu-vimlist-$groupname.txt | tr "\n" " "`
else
	echo '[ERROR] groupname is empty'
fi
