#!/bin/bash
#
# This script packages the yum-repo-server

# Declaration of the parameters
VERSION=$(cat pom.xml | grep version | head -1 | awk -F 'version' '{print $2}' | sed -s 's/^>//g' | sed -s 's/<\/$//g')
PACKAGEVERSION=`echo $VERSION | cut -d '.' -f 1`
ITERATION=`echo $VERSION | cut -d '.' -f 2`
ITERATIONPLUS=`echo $VERSION | cut -d '.' -f 3`

# Check if the version has a subsubversion
if [ -n "$ITERATIONPLUS" ]; then
          ITERATION=$ITERATION.$ITERATIONPLUS
fi

# Create the actual rpm package using fpm
cd target/yum-repo-server/
fpm -s dir -t rpm -v $VERSION --url https://github.com/immobilienscout24/yum-repo-server --epoch $BUILD_NUMBER --iteration $BUILD_NUMBER --depends java-1.7.0-openjdk-devel --prefix /opt/jetty/webapps/yum-repo-server -a all -n yum-repo-server .
