#!/bin/bash

# +--------+----------------------+
# |FUNCTION| func_statusbar       |
# +--------+----------------------+
# |ARGUMENT| $1: Action Name      |
# +--------+----------------------+
func_statusbar()
{
	echo "[ACT]=>$1"
	echo "[PWD]=>`pwd`"
}

# +--------+----------------------+
# |FUNCTION| func_checkfilecount  |
# +--------+----------------------+
# |ARGUMENT|                      |
# +--------+----------------------+
func_checkfilecount()
{
	filecount=`ls | wc -l`
	if [ "$filecount" == "0" ]; then
		echo "[EMPTY]"
	else
		ls
	fi
}

# fix space to effect array result
IFS=$'\012'

nextRelativeChdir=$1
secondCondition=$2

# if empty of variable, then go back directory
if [ "$nextRelativeChdir" == "" ]; then
	func_statusbar 'THE-LAST-TIME-DIR'
	cd -
	# check file count and ls action
	func_checkfilecount
else

	# load dir list into basharray
	dirList=(`ls -aF | grep / | grep -ir ^$nextRelativeChdir`)
	
	if [ "${#dirList[@]}" == "1" ]; then
		cd ${dirList[0]}
		func_statusbar 'INTO-DIR'
	
		# check file count and ls action
		func_checkfilecount

	elif [ "${#dirList[@]}" -gt "1" ]; then
	
		# if have duplicate dirname then CHDIR
		Success="0"
		for dirDuplicatelist in ${dirList[@]}
		do
			if [ "$dirDuplicatelist" == "$nextRelativeChdir/" ]; then
				cd $nextRelativeChdir

				func_statusbar 'INTO-LUCK-DIR'
	
				# check file count and ls action
				func_checkfilecount
				Success="1"
				break
			fi
		done

		# if have secondCondition, DO secondCheck
		if [ "$secondCondition" != "" ]; then
			dirList2=(`ls -aF | grep / | grep -ir ^$nextRelativeChdir | grep -ir $secondCondition`)
			if [ "${#dirList2[@]}" == "1" ]; then
				cd ${dirList2[0]}

				func_statusbar 'INTO-LUCK-DIR-BY-SECOND-CONDITION'
	
				# check file count and ls action
				func_checkfilecount
				Success="1"
			fi
		fi
	
		# if no duplicate dirname then print them
		if [ $Success == "0" ]; then
			func_statusbar 'PLEASE-SELECT-ONE-INTO'
			for echothem in ${dirList[@]}
			do
				echo $echothem
			done
		fi
	else
		func_statusbar 'NOT-FOUND-OR-NOT-EXIST'
	fi
fi

