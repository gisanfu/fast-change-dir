#!/bin/bash

ga

listmode='ls -la --color=auto'

# all 顯示所有檔案，含資料夾和檔案
# dir 只顯示資料夾，並把位置列出來
# file 跟上面一樣，不過是檔案
filelist="all"

# 當filelist的值是all的時候，這個數值才會有作用
filemode='dir'

while [ 1 ];
do
	clear
	echo '工具列表(/斜線)   列表切換(*星號)   上一層(-減號)   檔案[夾]切換(.點)'
	echo '================================================='
	echo "目前顯示模式$listmode"
	echo "目前列表依據$filelist"
	echo "目前檔案模式$filemode"
	echo '================================================='
	eval $listmode
	read -n 1 cmd
	if [ "$cmd" == "q" ]; then
		echo '謝謝您的使用'
		break
	elif [ "$cmd" == "+" ]; then
		echo '請輸入9以上的數字項目'
		read cmd
	elif [ "$cmd" == "*" ]; then
		if [ "$listmode" == "ls -la --color=auto" ]; then
			listmode='ls --color=auto'
		else
			listmode='ls -la --color=auto'
		fi
	elif [ "$cmd" == "." ]; then
		if [ "$filemode" == "dir" ]; then
			filemode='file'
		else
			filemode='dir'
		fi
	elif [ "$cmd" == "-" ]; then
		ge
	elif [ "$cmd" == "/" ]; then
		echo '(1) dv 顯示虛擬資料夾'
		echo '(1) vff 將暫存檔案用VIM逐一打開'
		echo '(1) vfff VIM編輯暫存檔案列表'
		read -n 1 cmdslash
		if [ "$cmdslash" == "1" ]; then
			dv
		elif [ "$cmdslash" == "2" ]; then
			echo 'blha'
		fi
	fi

	if [[ "$cmd" =~ [[:digit:]] ]]; then
		if [ "$filemode" == "dir" ]; then
			selectitem=". /bin/gisanfu-pos-cddir.sh $cmd"
			eval $selectitem
		else
			echo '(1) vim 編輯此檔案'
			echo '(2) vf 將此檔案暫存'
			read -n 1 cmdslash
			if [ "$cmdslash" == "1" ]; then
				selectitem=". /bin/gisanfu-pos-editfile.sh $cmd"	
				eval $selectitem
			elif [ "$cmdslash" == "2" ]; then
				selectitem=". /bin/gisanfu-pos-vimlist-append.sh $cmd"
				eval $selectitem
			fi
		fi
	fi
done
