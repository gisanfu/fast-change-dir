#!/bin/bash

if [ "$groupname" != "" ]; then
	vim ~/gisanfu-dirpoint-$groupname.txt
else
	echo '[ERROR] groupname is empty'
fi
