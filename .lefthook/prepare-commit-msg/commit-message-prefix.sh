#!/bin/zsh

echo $1
CURRENT=$(git branch | awk '$1==\"*\"{print $2}')
sed -i "1s/^/${CURRENT} /" $1