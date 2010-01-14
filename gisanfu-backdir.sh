#!/bin/bash

source 'gisanfu-function.sh'

cd $1
func_statusbar 'GOTO-PARENT-DIR'

# check file count and ls action
func_checkfilecount
