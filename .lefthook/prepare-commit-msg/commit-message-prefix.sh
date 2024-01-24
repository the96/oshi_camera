#!/bin/zsh

CURRENT=$(git branch | gawk '$1=="*"{print $2}')
gsed -i "1s/^/[${CURRENT}] /" $1