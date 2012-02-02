#!/bin/bash

# 跟一般的cd很像
# 只是會自動的把最右邊的檔名去除掉(如果有的話)，然後在進去該資料夾
# 而且不管是絕對路徑，或是相對路徑

# http://bashscripts.org/forum/viewtopic.php?f=16&t=365
#test script for file/path manipulation

# First, we'll need a path, so let's make one up

#fullpath="/mnt/test/this/is/a/ridiculously/long/path/to/test.file"

fullpathg=$1

if [ "$fullpathg" != "" ]; then

	# Now we'll chop the filename off of the end.  In awk, NF
	# is the Number of Fields.  If there are 10 fields, $NF is
	# equal to $10, or whatever the last field is.  We're using
	# the slash (/) as a field seperator (escaped with a "\"
	# filename="$(echo "$fullpath" |awk -F\/ '{ print $NF }')"

	# or using basename:
	#filenameg="$(basename "$fullpathg")"


	# Now I'm just being lazy and using sed to chop off the
	# filename that we grabbed for our $filename variable
	# (commenting this out, since finding 'dirname')
	# use this if you still want the trailing slash :)

	#directory="$(echo "$fullpath"|sed s/"$filename"/""/g)"


	# The dirname command!  This works even if the file
	# you give it doesn't actually exist.  It does chop off
	# the trailing slash though, so watch out for that.
	# Also, if you don't give it a full path, it will return
	# a relative path.

	directoryg="$(dirname "$fullpathg")"


	# Now for the output, in case anybody
	# wants to run this script as-is

	#echo "$fullpath"
	#echo "$directory"
	#echo "$filename"

	cd $directoryg

	unset directoryg
	#unset filename
	#unset fullpath
fi
