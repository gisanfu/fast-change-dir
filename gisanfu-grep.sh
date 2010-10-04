#!/bin/bash

#if [ "$groupname" != '' ]; then
#	dv root
#fi

tmpfile=/tmp/`whoami`-grep-$( date +%Y%m%d-%H%M ).txt

nowpath=`pwd`

unset condition
unset count

while [ 1 ];
do
	clear
	echo '即時搜尋檔案內容'
	echo '================================================='
	echo "現行資料夾: $nowpath"
	echo "目前您所輸入的搜尋關鍵字的條件: $condition"
	echo '================================================='

	if [ "$condition" == 'quit' ]; then
		break
	elif [ "$condition" != '' ]; then
		grep -ir $condition * --exclude-dir Zend --exclude-dir .svn --no-messages | sort --unique | nl -s: -w1 > $tmpfile
		cat $tmpfile
	fi

	echo '輸入完請按Enter，或者是輸入一個單引號，來選擇搜尋出來的編號'

	read inputvar

	condition="$inputvar"

	if [ "$inputvar" == '?' ]; then
		# 離開
		break
	elif [ "$inputvar" == '/' ]; then
		unset condition
		continue
	elif [[ "$inputvar" == "'" ]]; then
		echo '請輸入編號，輸入完請按Enter，輸入0是取消'
		read inputvar2
		selectfile=`grep "^$inputvar2:" $tmpfile | sed "s/^$inputvar2://" | cut -d: -f1`
		
		if [[ "$groupname" == '' && "$inputvar2" != '0' ]]; then
			run="vim $selectfile"
			eval $run
		elif [[ "$groupname" != '' && "$inputvar2" != '0' ]]; then
			# 檢查一下，看文字檔裡面有沒有這個內容，如果有，當然就不需要在append
			selectitem=''
			selectitem=`pwd`/$selectfile
			checkline=`grep "$selectitem" ~/gisanfu-vimlist-$groupname.txt | wc -l`
			if [ "$checkline" -lt 1 ]; then
				echo "\"$selectitem\"" >> ~/gisanfu-vimlist-$groupname.txt
				cat ~/gisanfu-vimlist-$groupname.txt
			else
				echo '[NOTICE] File is exist'
			fi
			selectitem=''

			# 問使用者，看要不要編輯這些檔案，或者是繼續Append其它的檔案進來
			echo '[WAIT] 確定，是編輯暫存檔案[Nf0,yj1]'
			read -n 1 inputvar3
			if [[ "$inputvar3" == 'y' || "$inputvar3" == 'j' || "$inputvar3" == "1" ]]; then
				/bin/gisanfu-vimlist.sh
			elif [[ "$inputvar3" == 'n' || "$inputvar3" == "f" || "$inputvar3" == "0" ]]; then
				echo "Your want append other file"
			else
				echo "Your want append other file"
			fi
		fi
		unset condition
	fi

done