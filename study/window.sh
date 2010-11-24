#!/bin/bash

# 切換到firefox的視窗，然後按下Ctrl+r重新refresh

wmctrl -R "firefox"

xmacroplay -d 10 $DISPLAY << ~~~
KeyStrPress Control_L
KeyStrPress r
KeyStrRelease r
KeyStrRelease Control_L
~~~

