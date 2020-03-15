#!/bin/sh -le

export GITHUB_TOKEN="${1}"
readonly GIT_USER_NAME="${2}"
readonly GIT_USER_EMAIL="${3}"
readonly BASE="${4}"
readonly REVIEWER="${5}"
readonly ASSIGN="${6}"
readonly MILESTONE="${7}"
readonly LABELS="${8}"
readonly DRAFT="${9}"
readonly GO_MOD_DIRCTORY="${10}"
readonly DEBUG="${11}"
readonly DUPLICATE="${12}"
readonly TIMEZONE="${13}"

readonly PR_TITLE_PREFIX="go mod tidy at "

if [ -n "${DEBUG}" ]; then
  set -x
  export HUB_VERBOSE="true"
fi

if [ -n "${TIMEZONE}" ]; then
  export TZ=$TIMEZONE
fi

export PATH="/go/bin:/usr/local/go/bin:$PATH"

cd $GO_MOD_DIRCTORY

go mod tidy

if [ -d vendor/ ]; then
  go mod vendor
fi

if [ $(git status | grep "nothing to commit, working tree clean" | wc -l) = "1" ]; then
  echo "go.sum is not updated"
  exit 0
fi

if [ -z "$DUPLICATE" ]; then
  if [ $(hub pr list | grep "${PR_TITLE_PREFIX}" | wc -l ) != "0" ]; then
    echo "Skip creating PullRequest because it has already existed"
    exit 0
  fi
fi

git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"

readonly BRANCH_NAME=go-mod-tidy-$(date +"%Y%m%d%H%M%S")

export GITHUB_USER=$(echo $GITHUB_REPOSITORY | cut -d "/" -f 1)
readonly REMOTE_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git remote add push_via_ci $REMOTE_URL
git checkout -b $BRANCH_NAME

if [ -d vendor/ ]; then
  git add vendor/
  git commit -am ":put_litter_in_its_place: go mod tidy && go mod vendor"
else
  git commit -am ":put_litter_in_its_place: go mod tidy"
fi

git push push_via_ci $BRANCH_NAME

if [ -n "$BASE" ]; then
  hub_args="$hub_args --base=$BASE"
fi

if [ -n "$REVIEWER" ]; then
  hub_args="$hub_args --reviewer=$REVIEWER"
fi

if [ -n "$ASSIGN" ]; then
  hub_args="$hub_args --assign=$ASSIGN"
fi

if [ -n "$MILESTONE" ]; then
  hub_args="$hub_args --milestone=$MILESTONE"
fi

if [ -n "$LABELS" ]; then
  hub_args="$hub_args --labels=$LABELS"
fi

if [ -n "$DRAFT" ]; then
  hub_args="$hub_args --draft"
fi

hub pull-request --no-edit --message="${PR_TITLE_PREFIX}$(date)" $hub_args
