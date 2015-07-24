#!/bin/bash
#
# This script is used by travis to remove the previous version of a package from package_cloud

set -ev

echo $1
echo $2
echo $TRAVIS_PULL_REQUEST

if [ $1 -eq 0 ] && [ $2 -eq 0 ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  if [ -f Modulefile ]; then
    MODULE_NAME=$(
      grep -i ^name Modulefile \
        | sed -e "s+\"+'+g" \
        | cut -d "'" -f2 \
        | cut -d '-' -f2
    )

    MODULE_VERSION=$(
      grep -i ^version Modulefile \
        | sed -e "s+\"+'+g" \
        | cut -d "'" -f2
    )
  fi

  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mRemove previous package from packagecloud repository \e[00m--- \e[1;34m]\e[00m\n"
  bundle exec package_cloud yank visibilityspots/puppet-development-modules/el/6 puppet-development-module-$MODULE_NAME-$MODULE_VERSION.x86_64.rpm
else
  echo -e "\e[01;31mLint/syntax checks failed or it consist of a pull request so no package stuff will be performed.\e[0m";
fi
