#!/bin/bash

source "$fast_change_dir/gisanfu-function.sh"

relativeitem=''
Success=0
tmpfile=/tmp/`whoami`-dialog-$( date +%Y%m%d-%H%M ).txt

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
				# to match file or dir rule
				if [ "$dirDuplicatelist" == "$nextRelativeItem/" ] || [ "$dirDuplicatelist" == "$nextRelativeItem" ]; then
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
			dialogitems=''
			for echothem in ${itemList[@]}
			do
				dialogitems=" $dialogitems $echothem '' "
			done

			cmd=$( func_dialog_menu 'Please Select Item' 70 "$dialogitems" "$tmpfile" )

			eval $cmd
			result=`cat $tmpfile`

			if [ -f "$tmpfile" ]; then
				rm -rf $tmpfile
			fi
			if [ "$result" == "" ]; then
				func_statusbar 'PLEASE-SELECT-ONE-ITEM'
				for echothem in ${itemList[@]}
				do
					echo $echothem
				done
			else
				relativeitem=$result
			fi
		fi
	else
		relativeitem=''
		func_statusbar 'NOT-FOUND-OR-NOT-EXIST'
	fi
fi

tmpfile=''
