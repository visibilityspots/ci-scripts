#/bin/bash
#
# This script will create an rpm package of the jetty software
#
# Declaration of parameters
CURRENT=$(cat ~/jobs/package-jetty/RELEASE | head -n 1)
RELEASE=$(curl -s http://download.eclipse.org/jetty/ | grep 'stable' | head -1 | awk -F '>' '{print $3}' | awk -F ':' '{print $1}')
VERSION=$(curl -s http://download.eclipse.org/jetty/ | grep Stable | head -1 | awk -F ' ' '{print $2}' | awk -F '.' '{print $1}')
ITERATION=$(curl -s http://download.eclipse.org/jetty/ | grep Stable | head -1 | awk -F ' ' '{print $2}' | awk -F '.v' '{print $1}' | awk -F "$VERSION." '{print $2}')
PRINTRELEASE=$VERSION-$ITERATION
BUILD_NUMBER=1

PACKAGE=$(curl -s "http://ftp.acc.umu.se/mirror/eclipse.org/jetty/stable-$VERSION/dist/" | grep tar | head -1 |  awk -F 'href=' '{print $2}' | sed -s 's/^"//g' | cut -d '"' -f1)
DOWNLOAD="http://saimei.acc.umu.se/mirror/eclipse.org/jetty/stable-$VERSION/dist/$PACKAGE"

## Check if newer version upstream
if [[ "$CURRENT" == "$PRINTRELEASE" ]];then
	echo "Nothing to do, already packaged latest release"
else
	# Download latest source, create package from it and move the generated rpm to the root workspace
	wget $DOWNLOAD
	tar -xvzf jetty*
	cd jetty*

	fpm -s dir -t rpm -v $VERSION --url eclipse.org/jetty --epoch $BUILD_NUMBER --iteration $ITERATION --prefix /opt/jetty --rpm-user jetty --rpm-group jetty --exclude logs --exclude webapps --depends java-1.7.0-openjdk --directories . -a all -n jetty .
	mv *.rpm ../
	echo $PRINTRELEASE > ../../RELEASE
fi
