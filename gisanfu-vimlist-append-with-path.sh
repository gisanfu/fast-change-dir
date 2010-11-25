#!/bin/bash

# 這支程式最初是要設計給abc v3裡面的搜尋檔案函式所使用

absoluteitem_path=$1
relativeitem_path=$2

if [[ "$absoluteitem_path" != '' && "$groupname" != '' ]]; then
	checkline=`grep "$absoluteitem_path" ~/gisanfu-vimlist-$groupname.txt | wc -l`
	if [ "$checkline" -lt 1 ]; then
		echo "\"$absoluteitem_path\"" >> ~/gisanfu-vimlist-$groupname.txt
	else
		echo '[NOTICE] File is exist'
	fi
elif [[ "$relativeitem_path" != '' && "$groupname" != ''  ]]; then
	# 要把前面那個點拿掉
	# 我指的是./aaa.txt前面那一個點
	selectitem=`pwd`/${relativeitem_path:1}
	checkline=`grep "$selectitem" ~/gisanfu-vimlist-$groupname.txt | wc -l`
	if [ "$checkline" -lt 1 ]; then
		echo "\"$selectitem\"" >> ~/gisanfu-vimlist-$groupname.txt
	else
		echo '[NOTICE] File is exist'
	fi
fi

if [ "$groupname" != '' ]; then
	# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
	echo '[WAIT] 預設是只暫存所選取的檔案 [N0,y1]'
	echo '[WAIT] 或是編輯列表 [j]'
	echo '[WAIT] 還是清空它 [k]'
	read -n 1 inputchar
	if [[ "$inputchar" == 'y' || "$inputchar" == "1" ]]; then
		# 取得最後append的檔案位置，這樣子vim -p以後就可以直接跳過該位置，就不用一直在gt..gt..gt..gt...
		checklinenumber=`cat ~/gisanfu-vimlist-$groupname.txt | nl -w1 -s: | grep "$selectitem" | head -n 1 | awk -F: '{print $1}'`
		cmd='vff "vim'
		for i in `seq 1 $checklinenumber`
		do
			cmd="$cmd +tabnext"
		done
		cmd="$cmd -p ~/gisanfu-vimlist-$groupname.txt\""
		eval $cmd
	elif [[ "$inputchar" == 'n' || "$inputchar" == "0" ]]; then
		echo "Your want append other file"
	elif [ "$inputchar" == 'j' ]; then
		vfff
	elif [ "$inputchar" == 'k' ]; then
		vffff
	else
		echo "Your want append other file"
	fi
else
	if [ "$absoluteitem_path" != '' ]; then
		vim $absoluteitem_path
	else
		vim $relativeitem_path
	fi
fi

# 結束前，把這裡所用到的變數給清空
relativeitem_path=''
absoluteitem_path=''
inputvar=''
checkline=''
selectitem=''
cmd=''
checklinenumber=''
