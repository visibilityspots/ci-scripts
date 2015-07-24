#!/bin/bash
#
#
set -ev

bundle exec package_cloud push visibilityspots/puppet-development-modules/el/6 *.rpm;
