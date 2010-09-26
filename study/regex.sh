#!/bin/bash

item='"dir"@'
# 正規的外面要用雙引包起來
regex="^\"(.*)\"@$"

if [[ "$item" =~ $regex ]]; then
	echo 'match symbolic'
	echo ${BASH_REMATCH[1]}
fi
