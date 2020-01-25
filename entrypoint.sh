#!/bin/sh -le

export GITHUB_TOKEN=$1
readonly REVIEWER=$2
readonly ASSIGN=$3
readonly MILESTONE=$4
readonly DRAFT=$5

echo "REVIEWER=$REVIEWER"
echo "ASSIGN=$ASSIGN"
echo "MILESTONE=$MILESTONE"
echo "DRAFT=$DRAFT"
