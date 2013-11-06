#!/bin/bash                                       
#                                                 
# This script will create an rpm package of the bacula-web software
                                                  
# Declaration of parameters                         
CURRENT=$(cat ~/jobs/package-bacula-web/RELEASE | head -n 1)      
PRINTRELEASE=$(curl -s http://www.bacula-web.org/download.html | grep '<p>Version:' | awk '{print $2}' | sed -r 's/<br//')              
RELEASE=$( curl -s http://www.bacula-web.org/download.html | grep '<p>Version:' | awk '{print $2}' | sed -r 's/<br//' | cut -d '-' -f 1)
ITERATION=$(curl -s http://www.bacula-web.org/download.html | grep '<p>Version:' | awk '{print $2}' | sed -r 's/<br//' | cut -d '-' -f 2)
                                                  
if [ -z "$ITERATION" ]                            
then ITERATION=0                                  
fi                                                
                                                  
# Check if newer version upstream                 
if [[ "$CURRENT" == "$PRINTRELEASE" ]]              
then echo "Nothing to do, already packaged latest release"
else                                              
  # Download latest source code and create package  
  wget http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-$PRINTRELEASE.tgz
  mkdir bacula-web                                  
  tar -xzf bacula-web-$PRINTRELEASE.tgz -C bacula-web
  cd bacula-web                                                   
  fpm -s dir -t rpm -v $RELEASE --url bacula-web.org --epoch $BUILD_NUMBER --iteration $ITERATION --prefix /var/www/bacula-web --rpm-user apache --rpm-group apache --directories . -a all -n bacula-web .
                                    
  # Move package to sartre repo                                   
  sudo mv bacula-web*.noarch.rpm  REPO-DIRECTORY
  echo $PRINTRELEASE > ~/jobs/package-bacula-web/RELEASE 
fi            
