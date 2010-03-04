#!/bin/bash

#source 'gisanfu-function.sh'

nextRelativeChdir=$1
secondCondition=$2

cd .. && . gisanfu-cddir.sh $nextRelativeChdir $secondCondition

if [ "$relativeitem" == "" ]; then
	cd -
fi
