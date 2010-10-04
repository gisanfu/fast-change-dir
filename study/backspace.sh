#!/bin/bash

backspace=$(echo -e \\b\\c)

echo 'please input backspace'
# 您可以利用Ctrl + H，就可以讀取到"倒退鍵"
read inputvar

if [ "$inputvar" == $backspace ]; then
	echo 'READ backspace!'
fi
