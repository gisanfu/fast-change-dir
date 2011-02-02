#!/bin/bash

# 這個函式，是要做行和列的位置排序
func_ls_sort()
{
	# terminal's width, my IBM nb is 100
	width=`tput cols`
}

func_ls()
{
	color_dir='\e[1;34m' # Blue
	color_file_run='\e[1;32m' # Green
	color_none='\e[0m' # No Color, or color end

	tmpdir=/tmp/`whoami`-func_ls-$( date +%Y%m%d-%H%M )

	# 如果是現行資料夾的話，這個變數可以為空白
	lspath=$1

	filelist=(`ls -AFQm -I .git -I .svn $lspath | tr "\n" " " | tr ", " " "`)

	# 包含顏色字元的結果變數
	# 這是用在最後顯示所使用
	color_result=''

	# 這跟color_result變數很類似
	# 但這個是運算用的
	result=''

	item_number=1

	for bbb in ${filelist[@]}
	do
		regex_dir="^\"(.*)\"/$"
		regex_file="^\"(.*)\"$"
		regex_file_run="^\"(.*)\"\*$"
		regex_symbolic="^\"(.*)\"@$"

		if [[ "$bbb" =~ $regex_dir ]]; then
			color="$color_dir"
		elif [[ "$bbb" =~ $regex_symbolic ]]; then
			# 如果是link，就看看它是資料夾還是檔案，各有各的顏色
			symcheck=`ls -LF | grep ^${BASH_REMATCH[1]}`
			if [[ "$symcheck" =~ $regex_dir ]]; then
				color="$color_dir"
			elif [[ "$bbb" =~ $regex_file ]]; then
				color=""
			elif [[ "$bbb" =~ $regex_file_run ]]; then
				color=""
			fi
		elif [[ "$bbb" =~ $regex_file ]]; then
			color=""
		elif [[ "$bbb" =~ $regex_file_run ]]; then
			color="$color_file_run"
		fi

		#if [ "$bbb" != '' ]; then
			item="($item_number)${BASH_REMATCH[1]}"
		#fi

		if [ "$color_result" == '' ]; then
			color_result="\"$color$item\""
		else
			color_result="$color_result \"$color$item"
		fi

		# 如果有顏色，就在後面補上顏色的結尾，也就是沒有顏色
		if [ "$color" != '' ]; then
			color_result="$color_result$color_none\""
		fi

		# 這個result變數是沒有在存放顏色的，是拿來算長度用的
		if [ "$result" == '' ]; then
			result="$item"
		else
			result="$result $item"
		fi

		item_number=$(($item_number+1))

	done

	mkdir_result=(`echo $result`)

	for bbb in ${mkdir_result[@]}
	do
		mkdir -p $tmpdir/$bbb
	done

	#echo -e "$color_result"
	ls $tmpdir --color=auto

	rm -rf $tmpdir
}

func_ls '.'
