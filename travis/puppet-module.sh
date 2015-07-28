#!/bin/bash
#
# This script will be used to perform tests on puppet code for the puppet-modules on git through travis

set -e

MODULE=$1
MODULE_ENVIRONMENT=$2
PUPPET_TREE="/etc/puppet/environments/$MODULE_ENVIRONMENT"
if [ -z "$3" ]; then PACKAGING=false; else PACKAGING=$3;fi

echo $PACKAGING

lint_fail="false"

if [ -d $MODULE ]; then
 cd $MODULE
fi

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
else
  echo "This module doesn't contains a Modulefile necassary to get package information"
  exit 1
fi

echo -e "\n\e[1;34m[\e[00m --- \e[00;32mLint & syntax check \e[00m--- \e[1;34m]\e[00m\n"


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
                bundle exec puppet parser validate --storeconfigs $i
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

echo


echo "Travis:  ${TRAVIS_PULL_REQUEST} & packaging: ${PACKAGING}"

if [ "$lint_fail" == "true" ]
then
  exit 1;
elif [ "${TRAVIS_PULL_REQUEST}" != "false" ] && [ "$PACKAGING" == "false" ]
then
  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mTests are passed sucessfully \e[00m--- \e[1;34m]\e[00m\n"
else
  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mRemove previous package from packagecloud repository \e[00m--- \e[1;34m]\e[00m\n"
  bundle exec package_cloud yank visibilityspots/puppet-development-modules/el/6 puppet-development-module-$MODULE_NAME-$MODULE_VERSION-1.x86_64.rpm

  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mPackage puppet-module $MODULE \e[00m--- \e[1;34m]\e[00m\n"

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
      --epoch 1 \
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
      --epoch 1 \
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

  echo -e "\n\e[1;34m[\e[00m --- \e[00;32mUpload package to packagecloud.io \e[00m--- \e[1;34m]\e[00m\n"
  bundle exec package_cloud push visibilityspots/puppet-development-modules/el/6 *.rpm;

fi
