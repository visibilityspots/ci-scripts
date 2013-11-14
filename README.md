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
