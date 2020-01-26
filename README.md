# go-mod-tidy-pr
Run `go mod tidy` and create PullRequest

https://github.com/marketplace/actions/go-mod-tidy-pr

## Example
![example](img/example.png)

https://github.com/sue445/go-mod-tidy-pr/pull/12

## Usage
```yaml
name: go-mod-tidy-pr

on:
  schedule:
    - cron: "0 0 * * 1" # Weekly build

jobs:
  go-mod-tidy-pr:
    name: go-mod-tidy-pr

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Run go-mod-tidy-pr
        uses: sue445/go-mod-tidy-pr@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          git_user_name: GitHub Actions
          git_user_email: github-actions@example.cpm
          # reviewer: foo
          # assign: foo
          # milestone: some_milestone
          # labels: go-mod-tidy
          # draft: "true"
          # go_mod_directory: "/dir/to/go-mod"
          # debug: "true"
          # duplicate: "true"
```

## Parameters
* `github_token` **Required**
  *  GitHub Token
* `git_user_name` **Required**
  * Username for commit
* `git_user_email` **Required**
  * E-mail for commit
* `base`
  * The base branch in the "[OWNER:]BRANCH" format. Defaults to the default branch of the upstream repository (usually "master").
  * See https://hub.github.com/hub-pull-request.1.html
* `reviewer`
  * A comma-separated list (no spaces around the comma) of GitHub handles to request a review from.
  * See https://hub.github.com/hub-pull-request.1.html
* `assign`
  * A comma-separated list (no spaces around the comma) of GitHub handles to assign to this pull request.
  * See https://hub.github.com/hub-pull-request.1.html
* `milestone`
  * The milestone name to add to this pull request. Passing the milestone number is deprecated.
  * See https://hub.github.com/hub-pull-request.1.html
* `labels`
  * A comma-separated list (no spaces around the comma) of labels to add to this pull request. Labels will be created if they do not already exist.
  * See https://hub.github.com/hub-pull-request.1.html
* `draft`
  * Create the pull request as a draft.
  * See https://hub.github.com/hub-pull-request.1.html
* `go_mod_directory` **Required**
  * Directory where `go.mod` is located
  * Default. `.`
* `debug`
  * Whether print debug logging
* `duplicate`
  * Whether create PullRequest even if it has already existed
