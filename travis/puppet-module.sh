#!/bin/bash
#
# This script will be used to perform tests on puppet code for the puppet-modules on git through travis

set -e

echo -e "\n\e[1;34m[\e[00m --- \e[00;32mLintian check \e[00m--- \e[1;34m]\e[00m\n"
lint_fail="false"
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
                error=$(bundle exec puppet-lint $i | wc -l)
                if [ "$error" != "0" ]; then
                        echo -e "* $i: [\e[01;31mNOT OK\e[0m]:";
                        bundle exec puppet-lint --log-format "%{line}:%{KIND}:%{message}" $i | while read line;
                        do
                                echo "=> $line"
                        done
                        lint_fail="true"
                else
                        echo -e "* $i: [\e[00;32mOK\e[0m]";
                fi
        done
fi

if [ "$lint_fail" == "true" ]; then
  echo
  echo -e "\e[01;31mLint check failed.\e[0m";
  exit 1;
else
  exit 0;
fi


echo -e "\n\e[1;34m[\e[00m --- \e[00;32mSyntax check \e[00m--- \e[1;34m]\e[00m\n"
syntax_fail="false"
if [ ! -z "$1" ];
then
        cd $1
fi

for i in ${files[@]};
do
  bundle exec puppet parser validate --storeconfigs $i
  error=(bundle exec puppet parser validate --storeconfigs $i | wc -l)
  if [ "$error" != "0" ]; then
    echo -e "* $i: [\e[01;31mNOT OK\e[0m]:";
    bundle exec puppet parser validate --storeconfigs $i
    syntax_fail="true"
   else
    echo -e "* $i: [\e[00;32mOK\e[0m]";
  fi
done

if [ "$syntax_fail" == "true" ]; then
  echo
  echo -e "\e[01;31mSyntax check failed.\e[0m";
  exit 1;
else
  exit 0;
fi
