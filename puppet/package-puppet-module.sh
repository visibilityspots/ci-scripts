#!/bin/bash
#
# This script uses the Module file from a puppet-module to create a deb or rpm package
# which could be deployed using a custom repository
set -ev

MODULE=$1
MODULE_ENVIRONMENT=$2
PUPPET_TREE="/etc/puppet/environments/$MODULE_ENVIRONMENT"

if [ $3 -eq 0 ] && [ $4 -eq 0 ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then

  if [ -d $MODULE ]; then
  	cd $MODULE
  fi

  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mPackage puppet-module $MODULE \e[00m--- \e[1;34m]\e[00m\n"

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

    MODULE_LICENSE=$(
      grep -i ^license Modulefile \
        | sed -e "s+\"+'+g" \
        | cut -d "'" -f2
    )

    MODULE_DESCRIPTION=$(
      grep -i ^description Modulefile \
        | sed -e "s+\"+'+g" \
        | cut -d "'" -f2
    )

    MODULE_URL=$(
      grep -i ^project_page Modulefile \
        | cut -d "'" -f2
    )

    # Build package with or without the --depends param based on Modulefile dependencies
    if [ -n "$(grep -i ^dependency Modulefile)" ]
    then
      DEPENDENCY_NAME=$(
        grep -i ^dependency Modulefile \
          | sed -e "s+\"+'+g" \
          | cut -d "'" -f2 \
          | cut -d '/' -f2
      )
      DEPENDENCY_VERSION=$(
        grep -i ^dependency Modulefile \
          | sed -e "s+\"+'+g" \
          | cut -d "'" -f4
      )
      FPM_DEPENDS="puppet-${MODULE_ENVIRONMENT}-module-${DEPENDENCY_NAME} ${DEPENDENCY_VERSION}"

      bundle exec fpm -s dir -t rpm \
        -v ${MODULE_VERSION} \
        --license "${MODULE_LICENSE}" \
        --url "${MODULE_URL}" \
        --prefix "${PUPPET_TREE}/modules/${MODULE_NAME}" \
        --category "puppet" \
        --depends "${FPM_DEPENDS}" \
        --description "${MODULE_DESCRIPTION}" \
        -n puppet-${MODULE_ENVIRONMENT}-module-${MODULE_NAME} \
        --exclude .gem* \
        --exclude .gitignore \
        --exclude Modulefile \
        --exclude README* \
        --exclude CHANGELOG \
        --exclude LICENSE \
        --exclude metadata* \
        --exclude NOTICE \
        --exclude ORIGIN \
        --exclude .project \
        --exclude .vim* \
        --exclude .travis.yml \
        --exclude fixtures.yml \
        --exclude .project \
        --exclude .puppet-lint.rc \
        --exclude .rspec \
        --exclude Gemfile \
        --exclude Rakefile \
        --exclude spec \
        --exclude spec.* \
        --exclude tests \
        --exclude .*.lock \
        --exclude .*.swp \
        --exclude .git \
        .
    else

      bundle exec fpm -s dir -t rpm \
        -v ${MODULE_VERSION} \
        --license "${MODULE_LICENSE}" \
        --url "${MODULE_URL}" \
        --prefix "${PUPPET_TREE}/modules/${MODULE_NAME}" \
        --category "puppet" \
        --description "${MODULE_DESCRIPTION}" \
        -n puppet-${MODULE_ENVIRONMENT}-module-${MODULE_NAME} \
        --exclude .gem* \
        --exclude .gitignore \
        --exclude Modulefile \
        --exclude README \
        --exclude .project \
        --exclude .vim* \
        --exclude .travis.yml \
        --exclude fixtures.yml \
        --exclude .project \
        --exclude .puppet-lint.rc \
        --exclude .rspec \
        --exclude Gemfile \
        --exclude Rakefile \
        --exclude spec \
        --exclude tests \
        --exclude .*.lock \
        --exclude .*.swp \
        --exclude .git \
        .
    fi
  else
    echo "This module doesn't contains a Modulefile necassary to get package information"
    exit 1
  fi
else
  echo -e "\e[01;31mLint syntax checks failed or it consist of a pull request so no package stuff will be performed.\e[0m";
fi
