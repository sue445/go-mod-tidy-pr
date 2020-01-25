#!/bin/sh -le

export GITHUB_TOKEN=$1
readonly BASE=$2
readonly REVIEWER=$3
readonly ASSIGN=$4
readonly MILESTONE=$5
readonly DRAFT=$6
readonly GO_MOD_DIRCTORY=$7
readonly DEBUG=$8

if [ -n "${DEBUG}" ]; then
  set -x
fi

export PATH="/go/bin:/usr/local/go/bin:$PATH"

cd $GO_MOD_DIRCTORY

go mod tidy

if [ $(git status | grep "nothing to commit, working tree clean" | wc -l) = "1" ]; then
  echo "go.sum is not updated"
  exit 0
fi

branch_name=go-mod-tidy-$(date +"%Y%m%d%H%M%S")

git checkout -b $branch_name
git commit -am ":put_litter_in_its_place: go mod tidy"

if [ -n "$BASE" ]; then
  hub_args="$hub_args --base $BASE"
fi

if [ -n "$REVIEWER" ]; then
  hub_args="$hub_args --reviewer $REVIEWER"
fi

if [ -n "$ASSIGN" ]; then
  hub_args="$hub_args --assign $ASSIGN"
fi

if [ -n "$MILESTONE" ]; then
  hub_args="$hub_args --milestone $MILESTONE"
fi

if [ -n "$DRAFT" ]; then
  hub_args="$hub_args --draft"
fi

hub pull-request --push --no-edit $hub_args
