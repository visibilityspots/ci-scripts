CI scripts
==========

This repository contains scripts I wrote for a jenkins server to automate certain tasks

packaging/package-bacula-web.sh
-------------------------------

I created a jenkins job called package-bacula-web. In the root dir of this job (as user jenkins ~/jobs/package-bacula-web/RELEASE) a RELEASE file is kept to indicate which version has been packaged using jenkins.

On a weekly base this job will execute a managed script called "Package bacula-web".
Configured in Jenkins -> Manage Jenkins -> Mananged files -> Add a new Config -> Managed script file

  bash -e /var/lib/jenkins/jobs/jenkins-scripts/workspace/package-bacula-web.sh
  echo

As you can see I have a jenkins job called jenkins-scripts which will checkout at each commit so I have versioning in my Managed files.

After the package has been build using fpm I move it to a directory and start another jenkins job which will build a repository based on that directory using rpmbuild


repository/mirror-repository.sh
-------------------------------

We use this script as a managed jenkins script to mirror commits been made on our own git server to the github.com instance. Be aware that using this script, changes been made on the github.com between pushes from the mirror will be lost! So if using this script you must use your own git repository for developing new nifty features!

Hopefully you got one day forked and getting some pull requests on the github.com repository it is possible to merge that request using your own git repository and can be done like this:

(USER is the github.com username of the person who requested the pull request)

* git remote add USER git@github.com:USER/REPONAME.git master (add the fork remote to your local repository)
* git fetch USER                                              (fetch the data from the forked repository to your local repository)
* git checkout USER/master                                    (Point your local repository to the fetched branch)
           => '''Test''' the code from the pull request, when everything is working you can go ahead <=
* git checkout master                                         (Point your local repository to the master branch)
* git merge USER/master                                       (Merge the code from the USER/master branch to the master using a matching commit message)
* git push origin master                                      (Push the merged code to the master branch of your git instance)

In our case the jenkins job will be triggered and the github.com repository will be synced with the new created merge commit. As soon as this has been synced the pull request on github.com will be automatically closed based on your commit to your own git instance.

* git remote rm USER                                          (Remove the remote url from your local repository)

source: https://wincent.com/wiki/Setting_up_backup_(mirror)_repositories_on_GitHub#comment_10143 wincent.com

varia/update-raspbian-screenly.sh
---------------------------------

We have setted up some raspberries for showing some dashing (http://shopify.github.io/dashing/) dashboards using screenly (http://www.screenlyapp.com/ose.html). Because we doesn't want to manually update those little devices every once in a while I've scripted those steps.

In the beginning we were using this script running in cron on the device itself. But after a while I figured out we really wanted to have the script in a repository for versioning and keep track of the log of those updates. So I generated a jenkins jobs which runs once a week by using scp for copying the script to the home directory of the pi user on the raspberry and using execute shell on remote host using ssh to execute this script.

That way the raspbian operating system is updated and the screenly app if there are updates available.

repository/jenkins.php
----------------------

We are using the jenkins build with parameter plugin (https://wiki.jenkins-ci.org/display/JENKINS/Build+With+Parameters+Plugin) to trigger some abstractified jobs. But when implementing the webhook url in github enterprise we figured out a major issue.

Github uses a post request to trigger the url, but jenkins isn't able of interpreting the parameters besides the token. Which makes this webhook kinda useless. Therefore I wrote a simple php script which parses the post request parameters into a get request using curl.

I created an issue for this: https://issues.jenkins-ci.org/browse/JENKINS-21869

puppet/deploy-puppet-run.sh
---------------------------

When you want to deploy a puppet run on certain nodes using a puppetdb query through ansible this script can help you achieving that goal. Fill in the parameters or give them through the console when starting it and a puppet run will be deployed on the nodes which have a certain resource type declared through puppet.

puppet/package-puppet-manifests.sh
----------------------------------

To package your puppet manifests using fpm into an rpm you could go ahead with this one. It deploys them in the /etc/puppet/environments/ENVIRONMENT you specified when installing. I use this script for both development and production using environment as a parameter in the same jenkins job.

puppet/package-puppet-module.sh
-------------------------------

To package a puppet-module using fpm into an rpm package this job can help you. It collects some information from the Modulefile to add to the rpm package when building. The module will be deployed in the /etc/puppet/environments/ENVIRONMENT you specified when installing. I use this script for both development and production u    sing environment as a parameter in the same jenkins job.

puppet/puppet-check.sh
----------------------

Running puppet can be a real pain in the ... when you want to have it immediately install latest versions of packages from yum repositories. Therefore I started writing this script which cleans out the yum repository meta data for specific repositories.

The script also checks a /root/state.puppet file for the keyword enable*. That way developers can set the server in maintenance mode so puppet won't override their testing cases. And last but not least the script will pause for 2 seconds when another puppet run is already processing.
