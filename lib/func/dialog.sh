#!/bin/bash

# 這個是Dialog指令的選單功能
func_dialog_menu()
{
	text=$1
	width=$2
	content=$3
	tmp=$4

	cmd="dialog --menu '$text' 0 $width 20 $content 2> $tmp"
	echo $cmd
}

# 這個是Dialog指令的YesNo功能
func_dialog_yesno()
{
	title=$1
	text=$2
	width=$3

	cmd="dialog --title '$title' --yesno '$text' 7 $width"
	echo $cmd
}

# 這個是Dialog指令的inputbox功能
func_dialog_input()
{
	title=$1
	text=$2
	width=$3
	tmp=$4

	cmd="dialog --title '$title' --inputbox '$text' 7 $width 2> $tmp"
	echo $cmd
}
