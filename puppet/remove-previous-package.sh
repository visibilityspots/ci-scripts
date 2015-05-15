#!/bin/bash
#

i=$(git rev-list --all | wc -l)
ITERATION=$(( i - 1 ))

if [ -f Modulefile ]
then
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

#package_cloud yank visibilityspots/puppet-development-modules/el/6 puppet-development-module-$MODULE_NAME-$MODULE_VERSION-$ITERATION.x86_64.rpm

