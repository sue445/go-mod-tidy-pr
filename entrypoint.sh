#!/bin/sh -le

export GITHUB_TOKEN=$1
readonly REVIEWER=$2
readonly ASSIGN=$3
readonly MILESTONE=$4
readonly DRAFT=$5
readonly GO_MOD_DIRCTORY=$6

echo "REVIEWER=$REVIEWER"
echo "ASSIGN=$ASSIGN"
echo "MILESTONE=$MILESTONE"
echo "DRAFT=$DRAFT"
echo "GO_MOD_DIRCTORY=$GO_MOD_DIRCTORY"

cd $GO_MOD_DIRCTORY
pwd
