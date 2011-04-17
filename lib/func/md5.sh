#!/bin/bash

function func_md5() {
local length=${2:-32}
local string=$( echo "$1" | md5sum | awk '{ print $1 }' )
echo ${string:0:${length}}
}
