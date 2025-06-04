#!/bin/bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
HASH=$(git rev-parse HEAD)
MESSAGE=$(git log -1 --pretty=%B)

echo "$BRANCH" > git_info.txt
echo "$HASH" >> git_info.txt
echo "$MESSAGE" >> git_info.txt
