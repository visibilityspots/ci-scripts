#!/bin/bash
#
# This script will look up the nodes which contains a given resource and triggers a puppet run through ansible

# Initialize parameters
ENVIRONMENT=$1
TYPE=$2
RESOURCENAME=$3
PUPPETDB_HOST=puppetdb
PUPPETDB_PORT=8081

echo -e "\n\e[1;34m[\e[00m --- \e[00;32mQuery puppetdb nodes for $TYPE: $RESOURCENAME in the $ENVIRONMENT environment \e[00m--- \e[1;34m]\e[00m\n"

# Look up the nodes which have the given resource type and name declared through puppet
for NODE in $(curl --silent -G https://$PUPPETDB_HOST:$PUPPETDB_PORT/v4/environments/$ENVIRONMENT/resources/$TYPE/$RESOURCENAME | grep certname | awk -F ':' '{print $2}' | cut -d '"' -f2)
do
	nodes=("${nodes[@]}" $NODE)
done

# List the nodes if there are any
if [ ${#nodes[@]} -eq 0 ]; then

	echo "No nodes found to deploy package through"
else
	echo "Nodes to process:"
	echo "-----------------"
	echo ""

	for NODE in ${nodes[@]};
	do
		echo " * "$NODE;
	done

	echo -e "\n\e[1;34m[\e[00m --- \e[00;32mTrigger puppet runs through ansible in the $ENVIRONMENT environment  \e[00m--- \e[1;34m]\e[00m\n"

	for NODE in "${nodes[@]}"
	do
		echo "Process $NODE:"
		echo ""
		ansible $NODE -a "puppet agent --test" --sudo;
		echo "===================================================================================="
	done
fi
