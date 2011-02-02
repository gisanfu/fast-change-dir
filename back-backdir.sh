#!/bin/bash

source "$fast_change_dir_func/normal.sh"

Position=$1
dot='../'
dots=''

for (( i=1;i<=$Position;i++)); do
	dots=$dots$dot
done 
cd $dots

# check file count and ls action
func_checkfilecount
