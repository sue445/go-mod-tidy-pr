#!/bin/sh -le

export GITHUB_TOKEN=$1
readonly REVIEWER=$2
readonly ASSIGN=$3
readonly MILESTONE=$4
readonly DRAFT=$5
readonly GO_MOD_DIRCTORY=$6

set -x

export PATH="/go/bin:/usr/local/go/bin:$PATH"

cd $GO_MOD_DIRCTORY

go mod tidy

if [ $(git status | grep "nothing to commit, working tree clean" | wc -l) = "1" ]; then
  echo "go.sum is not updated"
  exit 0
fi
