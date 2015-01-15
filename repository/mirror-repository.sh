#!/bin/bash
#
# This script will mirror all changes from a git server to the github.com server

# Declaration of parameters
repo=$1
ownGitServer=git.domain.be
organisation=organisationName


echo -e "\n\e[1;34m[\e[00m --- \e[00;32mMirror own git repository to github.com: ${DIR}/${SUBDIR} --- \e[1;34m]\e[00m\n"

# Remove existing mirror directory
if [ -d "mirror-$repo" ]; then
    rm mirror-$repo -rf
fi

# Grab the own repo and mirror him to the github.com
git clone --mirror git@$ownGitServer:$organisation/$repo.git mirror-$repo
cd mirror-$repo
git remote set-url --push origin git@github.com:$organisation/$repo.git
git fetch -p origin
git push --mirror

