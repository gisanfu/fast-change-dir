#!/bin/bash

# IDEA
# 1. 按數字1，可能就顯示跟1有關係的項目，例如1、1N、1NN
# 2. filelist=all的時候，每一個項目都會加上數字，
#    當我選數字的時候，會自動去判斷這個項目是資料夾還是檔案

# 3種檔案變數
# 1.檔案顯示模式(mode)
#   指的是"ls -A"指令，要不要加上l
#   a.有l的是列出所有檔案(直式) - detail
#   b.沒有加的是跟著前面列出來(橫式) - normal
# 2.檔案列表方式(list)
#   a.顯示所有檔案和資料夾(不會加上任何的指令) - all
#   b.只顯示資料夾，後面也是會加上編號 - dir
#   c.只顯示檔案，檔案後面還會加上編號 - file
# 3.檔案指標種類(point)
#   這個應該不會在使用

funcGetMode()
{
	filemode=$1	
	filelist=$2

	cmd='ls -AF --color=auto'

	if [ "$filemode" == 'detail' ]; then
		cmd="$cmd -l"
	fi

	#if [[ "$filelist" == 'dir' || "$filelist" == 'file' ]]; then
	#	if [ "$filemode" == 'detail' ]; then
	#		cmd="$cmd | head -n -1"
	#	fi
	#fi

	if [ "$filelist" == 'dir' ]; then
		cmd="$cmd | grep \/$ | nl -s': '"
	elif [ "$filelist" == 'file' ]; then
		# 行號行0開始的原因是，第一行的總數弄不掉...@@
		cmd="$cmd | grep -v \/ | nl -v0 -s': '"
	fi

	echo $cmd
}

# 我想還是不要一開始就選好了
#ga

# -A 代表不顯示.和..，這個參數不能跟小a一起使用
# ls -A --color=auto'
filemode='detail'

# all 顯示所有檔案，含資料夾和檔案
# dir 只顯示資料夾，並把位置列出來
# file 跟上面一樣，不過是檔案
filelist='all'

# 當使用者檔案列表方式是all，然後選擇了某一個項目
# 這時這個變數就會是1，要告訴使用者要先選擇file or dir的檔案列表方式
filelisterr='0'

while [ 1 ];
do
	clear
	echo '工具列表(/斜線)   列表切換(*星號)   上一層(-減號)   檔案[夾]切換(0零)   列表依據切換(.點)'
	echo '================================================='
	echo "目前顯示模式$filemode"
	echo "目前列表方式$filelist"
	echo '================================================='

	if [ "$filelisterr" == '1' ]; then
		echo '[ERROR] 請按.(點)先切換檔案列表方式為file或是dir'
		#filelisterr='0'
	fi

	filecmd=$( funcGetMode "$filemode" "$filelist" )
	echo "debug => $filecmd"
	echo "debug => $filelist"
	eval $filecmd

	# 只是做一個分隔而以
	echo '================================================='

	if [ "$filelisterr" == '1' ]; then
		echo '[ERROR] 請按.(點)先切換檔案列表方式為file或是dir'
		filelisterr='0'
	fi

	# 請使用者做第一次的輸入指令
	echo '請輸入指令:'

	read -n 1 cmd

	if [ "$cmd" == "q" ]; then
		echo '謝謝您的使用'
		break
	elif [ "$cmd" == "+" ]; then
		echo '請輸入9以上的數字項目'
		read cmd
	elif [ "$cmd" == "*" ]; then
		if [ "$filemode" == "normal" ]; then
			filemode='detail'
		else
			filemode='normal'
		fi
	elif [ "$cmd" == "." ]; then
		if [ "$filelist" == "all" ]; then
			filelist='dir'
		elif [ "$filelist" == "dir" ]; then
			filelist='file'
		else
			filelist='all'
		fi
	elif [ "$cmd" == "-" ]; then
		ge
		filelist='all'
	elif [ "$cmd" == "/" ]; then
		echo '(1) ga 選擇專案'
		echo '(2) dv 顯示虛擬資料夾'
		echo '(3) vff 將暫存檔案用VIM逐一打開'
		echo '(4) vfff VIM編輯暫存檔案列表'
		echo '(5) 清除VIM編輯暫存檔案列表'
		echo '(Enter) 取消'
		echo '請輸入指令:'
		read -n 1 cmdslash
		if [ "$cmdslash" == "1" ]; then
			ga	
			cmd=''
		elif [ "$cmdslash" == "2" ]; then
			dv
		elif [ "$cmdslash" == "3" ]; then
			vff
		elif [ "$cmdslash" == "4" ]; then
			vfff
		elif [ "$cmdslash" == "5" ]; then
			if [ "$groupname" != '' ]; then
				rm ~/gisanfu-vimlist-$groupname.txt
				touch ~/gisanfu-vimlist-$groupname.txt
			fi
		fi
	fi

	# 只是做一個分隔而以
	echo '================================================='

	if [[ "$cmd" =~ [[:digit:]] ]]; then
		if [ "$filelist" == 'all' ]; then
			echo '請選擇列表方式，才能繼續下一步'
			echo '(1) 資料夾(預設)'
			echo '(2) 檔案'
			echo '請輸入指令:'
			read -n 1 cmdslash

			if [ "$cmdslash" == "2" ]; then
				filelist='file'
			else
				filelist='dir'
			fi
		fi

		if [ "$filelist" == "dir" ]; then
			selectitem=". /bin/gisanfu-pos-cddir.sh $cmd"
			eval $selectitem
			filelist='all'
		else
			# 以groupname(ga)來選擇動作，這樣子可能會比較順
			if [ "$groupname" == "" ]; then
				selectitem=". /bin/gisanfu-pos-editfile.sh $cmd"	
				eval $selectitem
			else
				selectitem=". /bin/gisanfu-pos-vimlist-append.sh $cmd"
				eval $selectitem
			fi
			filelist='all'
		fi
		
	fi
done
