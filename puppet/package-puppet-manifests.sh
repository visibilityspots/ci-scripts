#!/bin/bash
#
# This script creates an rpm package from the puppet-manifests of a specific environment using fpm

ENVIRONMENT=$1
ITERATION=$(git rev-list --all | wc -l)
EPOCH=$ITERATION

cd environments/$ENVIRONMENT/manifests
fpm -s dir -t rpm \
        -v 1.0.0 \
        --license 'GPL' \
        --url "https://github.com/USERNAME/REPO" \
        --epoch $EPOCH \
        --iteration $ITERATION \
        --prefix "/etc/puppet/environments/$ENVIRONMENT/manifests" \
        --category "puppet" \
        --description "Puppet manifests for the $ENVIRONMENT environment" \
        -n puppet-$ENVIRONMENT-manifests \
        --directories . \
        .
