#!/bin/bash

action=$1
groupname=$2

if [ "$action" == "select" ]; then
	count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
	if [ "$count" == "0" ]; then
		export groupname=""
		echo "[ERROR] groupname is not exist by $groupname"
	else
		export groupname=$groupname
		echo '[OK] export groupname success'
	fi
elif [ "$action" == "append" ]; then
	count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
	if [ "$count" == "0" ]; then
		echo $groupname >> ~/gisanfu-groupname.txt
		echo '[OK] append groupname success'
	else
		echo "[ERROR] groupname is exist by $groupname"
	fi
elif [ "$action" == "edit" ]; then
	vim ~/gisanfu-groupname.txt
else
	echo '[ERROR] no support action'
fi
