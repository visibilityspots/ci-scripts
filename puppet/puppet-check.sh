#!/bin/bash
#
# Script which checks maintenance mode before running puppet
#
# Author: Jan Collijs

# Parameter declaration
LOCAL_STATE=$(cat /root/state.puppet)

# Loop to check if there is already a puppet run busy
while true
do
	[ ! -f /var/lib/puppet/state/agent_catalog_run.lock ] && break
	sleep 2
done

# Process the server maintenance mode
if [[ ! $LOCAL_STATE =~ ^enable* ]]; then
  LOCAL_STATE=0
else
  LOCAL_STATE=1
fi

# Check if puppet is in maintenance mode
if [ $LOCAL_STATE -eq 0 ]; then
  exit 0;
elif [ $LOCAL_STATE -gt 0 ]; then
  yum clean all --disablerepo="*" --enablerepo="*development*,*production*"
  puppet agent --test
  exit 0;
else
  exit 0;
fi
