#!/bin/bash

source 'gisanfu-function.sh'

Position=$1
cd .. && . /bin/gisanfu-pos-cddir.sh $Position

# check file count and ls action
func_checkfilecount
