Jenkins scripts
===============

This repository contains scripts I wrote for a jenkins server to automate certain tasks

package-bacula-web.sh
---------------------

I created a jenkins job called package-bacula-web. In the root dir of this job (as user jenkins ~/jobs/package-bacula-web/RELEASE) a RELEASE file is kept to indicate which version has been packaged using jenkins.

On a weekly base this job will execute a managed script called "Package bacula-web". 
Configured in Jenkins -> Manage Jenkins -> Mananged files -> Add a new Config -> Managed script file

  bash -e /var/lib/jenkins/jobs/jenkins-scripts/workspace/package-bacula-web.sh
  echo

As you can see I have a jenkins job called jenkins-scripts which will checkout at each commit so I have versioning in my Managed files.

After the package has been build using fpm I move it to a directory and start another jenkins job which will build a repository based on that direcotory using rpmbuild


mirror-repository.sh
--------------------

We use this script as a managed jenkins script to mirror commit's been made on our own git server to the github.com instance. Be aware that using this script, changes been made on the github.com between pushes from the mirror will be lost! So if using this script you must use your own git repository for developing new nifty features!

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

update-raspbian-screenly.sh
---------------------------

We have setted up some raspberries for showing some dashing (http://shopify.github.io/dashing/) dashboards using screenly (http://www.screenlyapp.com/ose.html). Because we doens't want to manually update those little devices every once in a while I've scripted those steps.

In the beginning we were using this script running in cron on the device itself. But after a while I figured out we really wanted to have the script in a repository for versioning and keep track of the log of those updates. So I generated a jenkins jobs which runs once a week by using scp for copying the script to the home directory of the pi user on the raspberry and using execute shell on remote host using ssh to execute this script.

That way the raspbian operating system is updated and the screenly app if there are updates available.

jenkins.php
-----------

We are using the jenkins build with parameter plugin (https://wiki.jenkins-ci.org/display/JENKINS/Build+With+Parameters+Plugin) to trigger some abstractified jobs. But when implementing the webhook url in github enterprise we figured out a major issue.

Github uses a post request to trigger the url, but jenkins isn't able of interpreting the parameters besides the token. Which makes this webhook kinda useless. Therefore I wrote a simple php script which parses the post request parameters into a get request using curl.
