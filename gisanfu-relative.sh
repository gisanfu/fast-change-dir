#!/bin/bash

source 'gisanfu-function.sh'

relativeitem=''

# if empty of variable, then go back directory
if [ "$nextRelativeItem" == "" ]; then
	func_statusbar 'LOSS-ARG-RELATIVE'
	relativeitem=''
else
	if [ "${#itemList[@]}" == "1" ]; then
		relativeitem=${itemList[0]}
		func_statusbar 'USE-ITEM'
	elif [ "${#itemList[@]}" -gt "1" ]; then

		if [ "$secondCondition" == "" ]; then
			# if have duplicate dirname then CHDIR
			Success="0"
			for dirDuplicatelist in ${itemList[@]}
			do
				if [ "$dirDuplicatelist" == "$nextRelativeItem/" ]; then
					relativeitem=$nextRelativeItem

					func_statusbar 'USE-LUCK-ITEM'
	
					Success="1"
					break
				fi
			done
		else
			# if have secondCondition, DO secondCheck
			if [ "${#itemList2[@]}" == "1" ]; then
				relativeitem=${itemList2[0]}

				func_statusbar 'USE-LUCK-ITEM-BY-SECOND-CONDITION'
	
				Success="1"
			fi
		fi
	
		# if no duplicate dirname then print them
		if [ $Success == "0" ]; then
			func_statusbar 'PLEASE-SELECT-ONE-INTO'
			for echothem in ${itemList[@]}
			do
				echo $echothem
			done
		fi
	else
		relativeitem=''
		func_statusbar 'NOT-FOUND-OR-NOT-EXIST'
	fi
fi

