#!/bin/bash

gitpath='/usr/local/git/bin/git'

while [ 1 ];
do
	clear

	echo 'Git指令模式 (英文字母)'
	echo '================================================='
	echo "現行資料夾: `pwd`"
	echo '================================================='
	echo '基本快速鍵:'
	echo ' 離開 (?)'
	echo 'Git功能快速鍵:'
	echo ' a. Status -s'
	echo ' b. Status'
	echo ' c. Update(Pull)'
	echo ' d. Commit(keyin changelog, and send by ask!)'
	echo ' e. Push(send!!)'
	echo '================================================='

	read -s -n 1 inputvar

	if [ "$inputvar" == '?' ]; then
		# 離開
		clear
		break
	elif [[ "$inputvar" == 'a' || "$inputvar" == 'A' ]]; then
		cmd="$gitpath status -s"
		eval $cmd
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的GIT簡易狀態'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'b' || "$inputvar" == 'B' ]]; then
		git status
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的GIT簡易狀態'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'c' || "$inputvar" == 'C' ]]; then
		git pull
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'd' || "$inputvar" == 'D' ]]; then
		echo '要送出了，但是請先輸入changelog，輸入完請按Enter'
		read changelog
		if [ "$changelog" == '' ]; then
			echo '為什麼你沒有輸入changelog呢？還是我幫你填上預設值呢？(no comment)好嗎？[Y1,n0]'
			read inputvar2
			if [[ "$inputvar2" == 'y' || "$inputvar2" == "1" ]]; then
				changelog='no comment'
			elif [[ "$inputvar2" == 'n' || "$inputvar2" == "0" ]]; then
				echo '如果不要預設值，那就算了'
			else
				echo '不好意思，不要預設值也不要來亂'
			fi
		fi
		if [ "$changelog" == '' ]; then
			echo '你並沒有輸入changelog，所以下次在見了，本次動作取消，倒數3秒後離開'
			sleep 3
		else
			git commit -m "$changelog"
			changelog=''
			if [ "$?" -eq 0 ]; then
				#echo '設定Changelog成功，別忘了要選擇送出哦'
				echo '要不要送出(git push)呢？[Y1,n0]'
				read inputvar3
				if [[ "$inputvar2" == 'n' || "$inputvar2" == "0" ]]; then
					echo '不要送出的話，那就算了！'
				else
					git push
				fi
			fi
			echo '按任何鍵繼續...'
			read -n 1
		fi
	elif [[ "$inputvar" == 'e' || "$inputvar" == 'E' ]]; then
		git push
		if [ "$?" -eq 0 ]; then
			echo '更新本GIT資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
