#!/bin/bash
#
# This script is used by travis to remove the previous version of a package from package_cloud

set -e

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
