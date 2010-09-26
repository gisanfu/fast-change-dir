#!/bin/bash

bldblu='\e[1;34m' # Blue
bldgrn='\e[1;32m' # Green
NC='\e[0m' # No Color

filelist=(`ls -AFQm -I .git -I .svn | tr "\n" " " | tr ", " " "`)

result=''

for bbb in ${filelist[@]}
do
	regex_dir="^\"(.*)\"/$"
	regex_file="^\"(.*)\"$"
	regex_file_run="^\"(.*)\"\*$"
	regex_symbolic="^\"(.*)\"@$"

	if [[ "$bbb" =~ $regex_dir ]]; then
		result="$result\t${bldblu}${BASH_REMATCH[1]:0:7}${NC}"
	elif [[ "$bbb" =~ $regex_symbolic ]]; then
		# 如果是link，就看看它是資料夾還是檔案，各有各的顏色
		symcheck=`ls -LF | grep ^${BASH_REMATCH[1]:0:7}`
		#echo $symcheck
		if [[ "$symcheck" =~ $regex_dir ]]; then
			result="$result\${bldblu}${BASH_REMATCH[1]}${NC}"
		elif [[ "$bbb" =~ $regex_file ]]; then
			result="$result\t${BASH_REMATCH[1]:0:7}"
		elif [[ "$bbb" =~ $regex_file_run ]]; then
			result="$result\t${bldgrn}${BASH_REMATCH[1]:0:7}${NC}"
		fi
	elif [[ "$bbb" =~ $regex_file ]]; then
		result="$result\t${BASH_REMATCH[1]:0:7}"
	elif [[ "$bbb" =~ $regex_file_run ]]; then
		result="$result\t${bldgrn}${BASH_REMATCH[1]:0:7}${NC}"
	fi
done

echo -e "$result"
