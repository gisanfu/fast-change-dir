#!/bin/bash

# 切換到firefox的視窗，然後按下Ctrl+r重新refresh

cmd=$1

if [ "$cmd" == '' ]; then
	echo '[INPUT] 請選擇切換到firefox後的動作'
	echo 'Refresh (YRr)*'
	echo 'Switch Only (Nn)'
	read -n 1 inputvar
	if [[ "$inputvar" == 'Y' || "$inputvar" == 'y' || "$inputvar" == 'R' || "$inputvar" == 'r' ]]; then
		cmd='refresh'
	elif [[ "$inputvar" == 'N' || "$inputvar" == 'n' ]]; then
		cmd='switchonly'
	else
		cmd='refresh'
	fi
fi

wmctrl -R "firefox"

if [ "$cmd" == 'refresh' ]; then
	xmacroplay -d 10 $DISPLAY << ~~~
KeyStrPress Control_L
KeyStrPress r
KeyStrRelease r
KeyStrRelease Control_L
~~~
fi
