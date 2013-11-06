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
