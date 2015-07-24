#!/bin/bash
#
# Script which performs a syntax check on the puppet code

set -e

echo -e "\n\e[1;34m[\e[00m --- \e[00;32mSyntax check \e[00m--- \e[1;34m]\e[00m\n"

if [ ! -z "$1" ];
then
        cd $1
fi

for FILE in $(find manifests/ -iname *.pp);
do
        if [ -f $FILE ];then
                files=("${files[@]}" $FILE)
        fi
done
if [ ${#files[@]} -eq 0 ];then
        echo "No puppet manifests to check"
else
        for i in ${files[@]};
        do
                bundle exec puppet parser validate --storeconfigs $i
                echo -e "* $i: [\e[00;32mOK\e[0m]";
        done
fi

echo
