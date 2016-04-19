Overview
========

This demo uses Developer Cloud Service to build and deploy the Spring PetClinic running on Tomcat to the Application Container Cloud with data stored in Database Cloud Service.


Prerequisites
=============

Inputs for this demo are:

1. SSH key for DBCS VM
2. Password for DBCS `system` user
3. Oracle.com SSO user id/password for access to the public Oracle Maven Repository required by the build

Setup
=====

Overview:

1. Create DBCS instance
2. Create DevCS PetClinic project cloning 'golden master' GIT Repository
3. Clone project GIT repository locally
4. Initialize the Database application user, schema, and contents
5. Encrypt Oracle.com SSO credentials to generate necessary Maven configuration files
6. Commit and push generated Maven credentials to DevCS GIT repository
7. Configure and run DevCS build
8. Define Deployment configuration and deploy

Create DBCS instance
--------------------

Create a DBCS service instance. The name of the service must be `MyDB` to match configuration values used in this example.

Create DevCS PetClinic Project
------------------------------

Create a new project cloning the `golden master` GIT repository that contains the PetClinic sample.

Clone project GIT repository
----------------------------

On your local computer, clone the GIT repository of your newly created DevCS project.

Initialize the Database
-----------------------
You'll need the database VM ip address which you can obtain from the service console.

Run `init-dbcs-pdb.sh` to create the `petclinic` application user, tables, and initial contents.  Usage is:

`init-dbcs-pdb.sh <db user> <db password> <ssh key file> <db server ip> [<PDB name>]`

For example:

    $ ./init-dbcs-pdb.sh system ooW_2015 ~/ssh/labkey 129.152.133.104
    create_user.sql                               100%   75     0.1KB/s   00:00    
    initDB.sql                                    100% 1620     1.6KB/s   00:00    
    populateDB.sql                                100% 3254     3.2KB/s   00:00    

    SQL*Plus: Release 12.1.0.2.0 Production on Thu Apr 14 21:12:43 2016

    Copyright (c) 1982, 2014, Oracle.  All rights reserved.

    Last Successful login time: Thu Apr 14 2016 21:03:05 +00:00

    Connected to:
    Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production

    SQL>
    User created.

    SQL>
    Grant succeeded.

    ...

    SQL> Disconnected from Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
    $

When running the init script on a fresh database you'll see some DROP TABLE failures because the script tries to clean up the database if run a second time.  Don't worry about the failure messages the first time you run it.

Encrypt Oracle.com SSO credentials
----------------------------------

This example uses the public Oracle Maven Repository which requires users to accept the terms and conditions and to authenticate when accessed.

To register and accept terms and conditions go to http://www.oracle.com/webapps/maven/register/license.html

Once you have done so you must [use your SSO credentials to access the repository](http://docs.oracle.com/cloud/latest/devcs_common/CSDCS/GUID-2C6E3DAA-E148-4D21-8507-3ECFB99E15C2.htm#CSDCS-GUID-E20C1FB7-FB70-41D9-A664-20387754647B).  This sample provides a utility to get this setup.

After you have cloned the git repo:

1.  Run `setup-mvn-security.sh`
2.  Provide your oracle.com user id
3.  Provide your oracle.com password
4.  The script will generate `settings.xml` and `settings-security.xml` files with your passwords encrypted.

Commit and push generated Maven credentials to DevCS GIT
--------------------------------------------------------

Add the generated `settings.xml` and `settings-security.xml` files to GIT, commit, and push them back to the DevCS GIT repo for use in the build.

    $ git add mvn/settings-security.xml mvn/settings.xml
    $ git commit -m "credentials"
      [master ea35e47] credentials
      2 files changed, 41 insertions(+)
      create mode 100644 mvn/settings-security.xml
      create mode 100644 mvn/settings.xml
    $ git push
    ...
    Counting objects: 5, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (5/5), done.
    Writing objects: 100% (5/5), 956 bytes | 0 bytes/s, done.
    Total 5 (delta 1), reused 0 (delta 0)
    remote: Resolving deltas: 100% (1/1)
    remote: Updating references: 100% (1/1)
    To ssh://..developer.us2.oraclecloud.com/../petclinic.git
    a7939ab..ea35e47  master -> master


Building the Application on Developer Cloud Service
---------------------------------------------------

Once you've created the Maven `settings.xml` and `setting-security.xml` files and pushed your project to the DevCS GIT repo you can build on DevCS by configuring the following build steps.  You'll need to add three Execute Shell steps to the default build, one before Maven runs, and two afterwards.

NOTE: The maven goal is **package**, not install.

**cp mvn/settings-security.xml ~/.m2/settings-security.xml**

![Execute shell `cp mvn/settings-security.xml ~/.m2/settings-security.xml`](images/buildstep-1.png "cp mvn/settings-security.xml ~/.m2/settings-security.xml")

**--settings=mvn/settings.xml clean package**
![Invoke Maven 3 `--settings=mvn/settings.xml clean package`](images/buildstep-2.png "--settings=mvn/settings.xml clean package")

**rm ~/.m2/settings-security.xml**
![Execute shell `rm ~/.m2/settings-security.xml`](images/buildstep-3.png "rm ~/.m2/settings-security.xml")

**sh package.sh**
![Execute shell `sh package.sh`](images/buildstep-4.png "sh package.sh")


The final step is to indicate what build artifact to archive.  Go to the build job's Post Build tab and in the Files to Archive field type "*.zip".  The output of the build is a deployable application archive which is a zip file.

![Archive *.zip](images/buildstep-5.png "Archive *.zip")

Automatic Builds
----------------

Enable firing off a build automatically when code is committed to the GIT repository.  On the build Triggers tab, check `Based on SCM poling schedule`.
![Automatic Build](images/buildstep-7.png "Automatic Build")



Creating the Application
------------------------

Because the application environment needs to be configure prior to deployment, we will create a sample application along with the necessary configuration, specifically the service binding to DBCS. Run `create-application.sh` with your identity domain, user id, and password.

`usage: ./create-application.sh <id domain> <user id> <user password>`

    $./create-application.sh jcsdemo230 demouser demopassword

After a minute or two you will see the created application along with the service binding in the ACCS service console.

![TomcatPetClinic](images/buildstep-6.png "TomcatPetClinic")


Deploying the Application from Developer Cloud Service
------------------------------------------------------

Once you have built the application successfully at least once, you can define a deployment configuration to automate deployment to ACCS.

1. Go to the project Deploy tab
2. Click New Configuration
3. Enter a deployment configuration name, e.g. "PetClinicDeploy"
4. Enter the application name.  This is the name of the application created by `create-application.sh` script, which is `TomcatPetClinic`.
5. Click on the Deployment Target field to get a drop down list.  Select your identity domain.
6. For Type, select Automatic.  This will deploy all successful builds automatically.
7. Select the default build name for the Job field.
8. Select the sole zip generated by the build as your Artifact to deploy.
9. Save the configuration.
10. Once saved, click on the Gear menu of the deployment and choose `Redeploy` to deploy the application archive.
11. Choose the last successful build (it should be the default) and click Deploy.


Exploring the Application
-------------------------

Navigate to the application by opening the URL provided at the top of the ACCS application details pages.  The base URL will take you to the Tomcat default page.  Add `/petclinic` to the end of the URL to see the application.

All data displayed in the user interface is read and written to the associated DBCS instance.
