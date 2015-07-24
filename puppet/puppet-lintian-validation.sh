#!/bin/bash
#
# Script which performs a puppet lint

set -e

echo -e "\n\e[1;34m[\e[00m --- \e[00;32mLintian check \e[00m--- \e[1;34m]\e[00m\n"

fail="false"


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
                        fail="true"
                else
                        echo -e "* $i: [\e[00;32mOK\e[0m]";
                fi
        done
fi

if [ "$fail" == "true" ]; then
  echo -e "\e[01;31mStyle check failed.\e[0m";
  exit 1;
else
  exit 0;
fi
