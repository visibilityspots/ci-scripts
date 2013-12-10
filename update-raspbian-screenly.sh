#!/bin/bash
#        
# A script which will run and update the os and screenly if updates are available for the raspberry
         
# Update & upgrade the rasbian operating system
echo -e "\n\e[1;34m[\e[00m --- \e[00;32mUpgrade raspbian OS: --- \e[1;34m]\e[00m\n"
sudo apt-get update -q -y
sudo apt-get upgrade -q -y
sudo apt-get dist-upgrade -q -y
sudo apt-get dselect-upgrade -q -y
         
# Clean out the cache & unused dependency packages
echo -e "\n\e[1;34m[\e[00m --- \e[00;32mClean raspbian OS: --- \e[1;34m]\e[00m\n"
sudo apt-get clean -q -y
sudo apt-get autoclean -q -y
         
# Run the screenly upgrade if updates are available
echo -e "\n\e[1;34m[\e[00m --- \e[00;32mUpgrade screenly if updates available: --- \e[1;34m]\e[00m\n"
if curl -s -k https://localhost/ | grep 'Update Available';then
        ~/screenly/misc/run_upgrade.sh -y
	sudo reboot
else     
        echo 'No screenly updates available'                                                                                                                                                                     
fi    
