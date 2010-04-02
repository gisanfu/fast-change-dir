#!/bin/bash

if [ "$groupname" != "" ]; then
	vim ~/gisanfu-vimlist-$groupname.txt
else
	echo '[ERROR] groupname is empty'
fi
