#!/bin/bash

if [ "$groupname" != "" ]; then
	vim $fast_change_dir_config/dirpoint-$groupname.txt
else
	echo '[ERROR] groupname is empty'
fi
