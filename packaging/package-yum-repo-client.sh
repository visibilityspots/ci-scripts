#!/bin/bash
#
# This script packages the yum-repo-client

# Declaration of the parameters
VERSION=$(cat pom.xml | grep version | head -1 | awk -F 'version' '{print $2}' |  sed -s 's/^="//g' | sed -s 's/".*$//g')
PACKAGEVERSION=`echo $VERSION | cut -d '.' -f 1`
ITERATION=`echo $VERSION | cut -d '.' -f 2`
ITERATIONPLUS=`echo $VERSION | cut -d '.' -f 3`

# Check if the version has a subsubversion
if [ -n "$ITERATIONPLUS" ]; then
          ITERATION=$ITERATION.$ITERATIONPLUS
fi

# Test the software
python setup.py test

# Create the actual rpm package
python setup.py bdist_rpm
