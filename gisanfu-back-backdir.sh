#!/bin/bash

source 'gisanfu-function.sh'

Position=$1
dot='../'
dots=''

for (( i=1;i<=$Position;i++)); do
	dots=$dots$dot
done 
cd $dots

# check file count and ls action
func_checkfilecount
