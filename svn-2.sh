#!/bin/bash

# 這是svn第2個版本，
# 主要的功能，是用快速鍵來操作

while [ 1 ];
do
	clear

	echo 'SVN (英文字母)'
	echo '================================================='
	echo "現行資料夾: `pwd`"
	echo '================================================='
	echo '基本快速鍵:'
	echo ' 離開 (?)'
	echo 'Svn功能快速鍵:'
	echo ' a. Status -q'
	echo ' b. Status'
	echo ' c. Update'
	echo ' d. Commit'
	echo '其它相關功能:'
	echo ' i. 以版本號編輯檔案 (別忘了使用前要先update一下) [需要ga]'
	echo '================================================='

	read -s -n 1 inputvar

	if [ "$inputvar" == '?' ]; then
		# 離開
		clear
		break
	elif [[ "$inputvar" == 'a' || "$inputvar" == 'A' ]]; then
		svn status -q
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的SVN狀態，但不顯示問號的動作成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'b' || "$inputvar" == 'B' ]]; then
		svn status
		if [ "$?" -eq 0 ]; then
			echo '顯示本資料夾的SVN狀態成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'c' || "$inputvar" == 'C' ]]; then
		svn update
		if [ "$?" -eq 0 ]; then
			echo '更新本SVN資料夾成功'
		fi
		echo '按任何鍵繼續...'
		read -n 1
	elif [[ "$inputvar" == 'd' || "$inputvar" == 'D' ]]; then
		echo '要送出了，但是請先輸入changelog，別忘了要大於5個字元，輸入完請按Enter'
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
			svn commit -m "$changelog"
			changelog=''
			if [ "$?" -eq 0 ]; then
				echo 'Commit成功'
			fi
			echo '按任何鍵繼續...'
			read -n 1
		fi
	elif [[ "$inputvar" == 'i' || "$inputvar" == 'I' ]]; then
		. /bin/gisanfu-dirpoint.sh root && svn log -v | more && /bin/gisanfu-svn-edit-revision.sh && cd -
	fi

done

# 離開前，在顯示一下現在資料夾裡面的東西
eval $cmd
