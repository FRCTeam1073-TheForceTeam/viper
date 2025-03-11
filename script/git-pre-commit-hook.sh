#!/bin/bash

status=0

files=`git diff --cached --name-only`

./script/console-log-check.sh $files
let status=status+$?

./script/tab-indent-check.sh $files
let status=status+$?

./script/final-new-line-check.sh $files
let status=status+$?

exit $status
