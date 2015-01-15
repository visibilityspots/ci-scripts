#!/bin/bash
#
# This script will create an rpm package of the monitis free agent

# Initialize workspace
mkdir monitis
cd monitis

# Get the source
wget http://dashboard.monitor.us/downloader/monitorus-agent-linux-64bit.tar.gz

LAST_MODIFIED_DATE=$(stat -c %y%m%d monitorus-agent-linux-64bit.tar.gz | awk '{print $1}' | sed 's/^..//' | sed 's/-//g')
LAST_COMPILED_DATE=$(head -1 ../../RELEASE)

if [ "$LAST_MODIFIED_DATE" -gt "$LAST_COMPILED_DATE" ]; then
  tar -xvzf monitorus-agent-linux-64bit.tar.gz

  VERSION=$(./monitis/bin/monitis -V | grep Agent | awk '{print $4}')
  PACKAGEVERSION="`echo $VERSION | awk -F '.' '{print $1}'`.`echo $VERSION | awk -F '.' '{print $2}'`"
  ITERATION=`echo $VERSION | awk -F '.' '{print $3}'`

  fpm -s dir -t rpm -v $VERSION --vendor monitor.us --url monitor.us --architecture x86_64 --description 'Monitis linux agent for the free monitor.us service' --iteration $BUILD_NUMBER --epoch $BUILD_NUMBER --prefix /etc --directories . -n monitis-agent monitis/

  # Reset the release
  echo $LAST_MODIFIED_DATE > ../../RELEASE
else
  echo "Nothing to do, already packaged latest release"
fi
