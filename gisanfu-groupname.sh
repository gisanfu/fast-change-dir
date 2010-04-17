#!/bin/bash

action=$1
groupname=$2

if [ "$action" == "select" ]; then
	if [ "$groupname" != "" ]; then
		count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
		if [ "$count" == "0" ]; then
			export groupname=""
			echo "[ERROR] groupname is not exist by $groupname"
		else
			export groupname=$groupname
			echo '[OK] export groupname success'
		fi
	else
		echo "[ERROR] please fill groupname field by select action"
	fi
elif [ "$action" == "append" ]; then
	if [ "$groupname" != "" ]; then
		count=`grep -ir $groupname ~/gisanfu-groupname.txt | wc -l`
		if [ "$count" == "0" ]; then
			echo $groupname >> ~/gisanfu-groupname.txt
			export groupname=$groupname
			echo '[OK] append and export groupname success'
		else
			echo "[ERROR] groupname is exist by $groupname"
		fi
	else
		echo "[ERROR] please fill groupname field by append action"
	fi
elif [ "$action" == "edit" ]; then
	vim ~/gisanfu-groupname.txt
else
	echo '[ERROR] no support action'
fi
