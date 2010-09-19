
#!/bin/bash

source 'gisanfu-function.sh'

# fix space to effect array result
IFS=$'\012'

filePosition=$1

if [ "$filePosition" != "" ]; then
	fileList=(`ls -AFL --file-type|grep -v "/$"`)
	if [ "${#fileList[@]}" -lt 1 ]; then
		func_statusbar 'THERE-IS-NO-FILE'
	else	
		if [ "${fileList[$filePosition - 1]}" == "" ]; then
			func_statusbar 'THIS-POSITION-IS-NO-FILE'
		else
			. /bin/gisanfu-vimlist-append.sh ${fileList[$filePosition - 1]}
		fi
	fi
else
	func_statusbar 'PLEASE-INPUT-ARG01'
fi
