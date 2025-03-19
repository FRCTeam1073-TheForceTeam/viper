#!/bin/bash

set -e

if [ ! -d .git/ ]
then
	exit 0
fi

ln -s -f ../../script/git-pre-commit-hook.sh .git/hooks/pre-commit
