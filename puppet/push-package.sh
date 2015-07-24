#!/bin/bash
#
#
set -ev

if [ $1 -eq 0 ] && [ $2 -eq 0 ] && [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  bundle exec package_cloud push visibilityspots/puppet-development-modules/el/6 *.rpm;
else
   echo -e "\e[01;31mLint/syntax checks failed or it consist of a pull request so no package stuff will be performed.\e[0m";
fi
