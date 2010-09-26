#!/bin/bash

aaa='aaa,bbb,ccc'

#echo ${aaa#*,}
arr1=(`echo "$aaa" | tr "," " "`)

for bbb in ${arr1[@]}
do
	echo $bbb
done
