#!/bin/bash

# 這個檔案是另外一個vff
# 我想取名vff2

# 這個程式的目的，很單純，只是離開vim了以後，在重新啟動vim
# 主要是重新讀取暫存清單

if [ "$groupname" == '' ]; then
	ga
fi

if [ "$groupname" != '' ]; then
	while [ 1 ];
	do
		vff
		echo '如果你想離開這個無限讀取暫存清單的迴圈停止'
		echo '請在這個時候按下Ctrl + C來中斷'
		sleep 2
	done
fi

if [ "$groupname" == '' ]; then
	echo '不好意思，你不給我群組名稱，我就不給你暫存清單!'
	sleep 3
fi
