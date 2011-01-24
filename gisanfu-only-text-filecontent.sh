#!/bin/bash

# 本程式目的
# 忽略掉純文字以外的檔案，例如壓縮檔

# 如果你要使用這支程式來當做pipe使用
# 請使用your-runfilename | xargs -n 1 this-file-name

aaa=$1

bbb=`file $aaa | grep -v text -v empty | wc -l`

if [ "$bbb" -gt 0 ]; then
	echo $aaa
fi
