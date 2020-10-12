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
readonly GO_VERSION="${11}"
readonly DEBUG="${12}"
readonly DUPLICATE="${13}"
readonly TIMEZONE="${14}"

readonly PR_TITLE_PREFIX="go mod tidy at "

install_go() {
  if [ -z "$GO_VERSION" ]; then
    go_version=$(curl -s https://api.github.com/repos/golang/go/git/refs/tags \
      | jq --raw-output '.[].ref | select(test("^refs/tags/go[0-9.]+$"))' \
      | tail -n 1 \
      | sed 's!refs/tags/go!!')
  else
    go_version=$GO_VERSION
  fi

  echo "installing Go $go_version"
  # from https://golang.org/doc/install#tarball
  go_tar=go$go_version.linux-amd64.tar.gz
  wget https://dl.google.com/go/"$go_tar"
  tar -C /usr/local -xzf "$go_tar"
  rm "$go_tar"
}

install_git_lfs() {
  git_lfs_url=$(curl -s https://api.github.com/repos/git-lfs/git-lfs/releases/latest \
    | jq --raw-output '.assets[] | select( .name | contains("linux-amd64") ) | .browser_download_url')

  echo "installing Git LFS (latest release)"
  wget "$git_lfs_url"

  git_lfs_tar="${git_lfs_url##*/}"
  mkdir -pv ./git-lfs
  tar -C ./git-lfs -zxvf "$git_lfs_tar"

  cd git-lfs
  ./install.sh
  cd ..

  rm "$git_lfs_tar"
  rm -rf git-lfs
}

if [ -n "$DEBUG" ]; then
  set -x
  export HUB_VERBOSE="true"
fi

if [ -n "$TIMEZONE" ]; then
  export TZ="$TIMEZONE"
fi

cd "$GO_MOD_DIRCTORY"

install_go
export PATH="$PATH":/usr/local/go/bin

install_git_lfs

git config --global url."https://$GITHUB_TOKEN:x-oauth-basic@github.com".insteadOf "https://github.com"

go mod tidy

if [ -d vendor/ ]; then
  go mod vendor
fi

if [ "$(git status | grep -c "nothing to commit, working tree clean")" = "1" ]; then
  echo "go.sum is not updated"
  exit 0
fi

if [ -z "$DUPLICATE" ]; then
  if [ "$(hub pr list | grep -c "$PR_TITLE_PREFIX")" != "0" ]; then
    echo "Skip creating PullRequest because it has already existed"
    exit 0
  fi
fi

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

readonly BRANCH_NAME=go-mod-tidy-$(date +"%Y%m%d%H%M%S")

GITHUB_USER="$(echo "${GITHUB_REPOSITORY:?}" | cut -d "/" -f 1)"
export GITHUB_USER
readonly REMOTE_URL="https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

git remote add push_via_ci "$REMOTE_URL"
git checkout -b "$BRANCH_NAME"

if [ -d vendor/ ]; then
  git add vendor/
  git commit -am ":put_litter_in_its_place: go mod tidy && go mod vendor"
else
  git commit -am ":put_litter_in_its_place: go mod tidy"
fi

git push push_via_ci "$BRANCH_NAME"

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

GITHUB_TOKEN=${GITHUB_TOKEN} hub pull-request --no-edit --message="$PR_TITLE_PREFIX$(date)" "$hub_args"
