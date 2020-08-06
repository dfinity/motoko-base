#!/bin/bash

set -e

echo
echo "  'Nightly Merge Action' is using the following input:"
echo "    - stable_branch = '$INPUT_STABLE_BRANCH'"
echo "    - development_branch = '$INPUT_DEVELOPMENT_BRANCH'"
echo "    - use_rebase = $INPUT_USE_REBASE"
echo "    - user_name = $INPUT_USER_NAME"
echo "    - user_email = $INPUT_USER_EMAIL"
echo "    - push_token = $INPUT_PUSH_TOKEN = ${!INPUT_PUSH_TOKEN}"
echo

if [[ -z "${!INPUT_PUSH_TOKEN}" ]]; then
  echo "Set the ${INPUT_PUSH_TOKEN} env variable."
  exit 1
fi

git remote set-url origin https://x-access-token:${!INPUT_PUSH_TOKEN}@github.com/$GITHUB_REPOSITORY.git
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

set -o xtrace

git fetch origin $INPUT_STABLE_BRANCH
git checkout -b $INPUT_STABLE_BRANCH origin/$INPUT_STABLE_BRANCH

git fetch origin $INPUT_DEVELOPMENT_BRANCH
git checkout -b $INPUT_DEVELOPMENT_BRANCH origin/$INPUT_DEVELOPMENT_BRANCH

if git merge-base --is-ancestor $INPUT_STABLE_BRANCH $INPUT_DEVELOPMENT_BRANCH; then
  echo "No merge is necessary"
  exit 0
fi;

set +o xtrace
echo
echo "  'Nightly Merge Action' is trying to merge the '$INPUT_STABLE_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_STABLE_BRANCH))"
echo "  into the '$INPUT_DEVELOPMENT_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_DEVELOPMENT_BRANCH))"
echo
set -o xtrace

# Do the merge/rebase
if $INPUT_USE_REBASE; then
  git rebase $INPUT_STABLE_BRANCH
else
  git merge --ff-only --no-edit $INPUT_STABLE_BRANCH
fi

# Push the branch
git push origin $INPUT_DEVELOPMENT_BRANCH
