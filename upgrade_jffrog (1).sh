#!/bin/bash

# steps to run the sript:
# upgrade_jffrog.sh 7.35.2

MAJOR_VERSION=$1
cd $ARTIFACTORY_HOME/bin
./artifactoryctl stop
tar -xvf jfrog-artifactory-pro-${MAJOR_VERSION}-linux.tar.gz
mkdir jfrog
mv jfrog-artifactory-pro-${MAJOR_VERSION}-linux jfrog/artifactory
export ARTIFACTORY_HOME=/var/opt/jfrog/artifactory
export JFROG_HOME=/var/opt/jfrog
export JF_PRODUCT_HOME=$JFROG_HOME/artifactory


# Artifactory data
mkdir -p $JFROG_HOME/artifactory/var/data/artifactory/
cp -rp $ARTIFACTORY_HOME/data/. $JFROG_HOME/artifactory/var/data/artifactory/
 
# Access data
mkdir -p $JFROG_HOME/artifactory/var/data/access/
cp -rp $ARTIFACTORY_HOME/access/data/. $JFROG_HOME/artifactory/var/data/access/
 
# Replicator data
# Note: If you've have never used the Artifactory Replicator
# your $ARTIFACTORY_HOME/replicator/ directory will be empty
mkdir -p $JFROG_HOME/artifactory/var/data/replicator/
cp -rp $ARTIFACTORY_HOME/replicator/data/. $JFROG_HOME/artifactory/var/data/replicator/
 
# Artifactory config
mkdir -p $JFROG_HOME/artifactory/var/etc/artifactory/
cp -rp $ARTIFACTORY_HOME/etc/. $JFROG_HOME/artifactory/var/etc/artifactory/
 
# Access config
mkdir -p $JFROG_HOME/artifactory/var/etc/access/
cp -rp $ARTIFACTORY_HOME/access/etc/. $JFROG_HOME/artifactory/var/etc/access/
 
# Replicator config
# Note: If you have never used the Artifactory Replicator
# your $ARTIFACTORY_HOME/replicator/ directory will be empty
mkdir -p $JFROG_HOME/artifactory/var/etc/replicator/
cp -rp $ARTIFACTORY_HOME/replicator/etc/. $JFROG_HOME/artifactory/var/etc/replicator/
 
# master.key
mkdir -p $JFROG_HOME/artifactory/var/etc/security/
cp -p $ARTIFACTORY_HOME/etc/security/master.key $JFROG_HOME/artifactory/var/etc/security/master.key
 
# server.xml
mkdir -p $JFROG_HOME/artifactory/var/work/old
cp -p $ARTIFACTORY_HOME/tomcat/conf/server.xml $JFROG_HOME/artifactory/var/work/old/server.xml
 
# artifactory.defaults
cp -rp $ARTIFACTORY_HOME/bin/artifactory.default $JFROG_HOME/artifactory/var/work/old/artifactory.default
#or, if Artifactory was installed a service
cp -rp $ARTIFACTORY_HOME/etc/default $JFROG_HOME/artifactory/var/work/old/artifactory.default
 
# External database driver, for example: mysql-connector-java-<version>.jar
mkdir -p $JFROG_HOME/artifactory/var/bootstrap/artifactory/tomcat/lib
cp -rp $ARTIFACTORY_HOME/tomcat/lib/<your database driver> $JFROG_HOME/artifactory/var/bootstrap/artifactory/tomcat/lib/<your database driver>
 
# Remove logback.xml with old links. Please consider migrating manually anything that is customized here
rm -f $JFROG_HOME/artifactory/var/etc/artifactory/logback.xml
rm -f $JFROG_HOME/artifactory/var/etc/access/logback.xml
 
# Move Artifactory logs
mkdir -p $JFROG_HOME/artifactory/var/log/archived/artifactory/
cp -rp $ARTIFACTORY_HOME/logs/. $JFROG_HOME/artifactory/var/log/archived/artifactory/
 
# Move configuration files
# Note: Run the following only when upgrading from Artifactory version 6.x to version 7.5.x and above.
mkdir -p $JFROG_HOME/artifactory/var/etc/artifactory/old
mkdir -p $JFROG_HOME/artifactory/var/etc/access/old
mkdir -p $JFROG_HOME/artifactory/var/etc/replicator/old
cp $JFROG_HOME/artifactory/var/etc/artifactory/db.properties  $JFROG_HOME/artifactory/var/etc/artifactory/old/db.properties
cp $JFROG_HOME/artifactory/var/etc/artifactory/ha-node.properties  $JFROG_HOME/artifactory/var/etc/artifactory/old/ha-node.properties
cp $JFROG_HOME/artifactory/var/etc/access/db.properties   $JFROG_HOME/artifactory/var/etc/access/old/db.properties
cp $JFROG_HOME/artifactory/var/etc/replicator/replicator.yaml  $JFROG_HOME/artifactory/var/etc/replicator/old/replicator.yaml

# For example: Replace any relative paths in the $ARTIFACTORY_HOME/etc/ha-node.properties file with absolute paths.
echo "artifactory.ha.data.dir=/var/opt/jfrog/artifactory-ha" >> $ARTIFACTORY_HOME/etc/ha-node.properties

# Artifactory backup (optional)
mkdir -p $JFROG_HOME/artifactory/var/backup/artifactory/
cp -rp $ARTIFACTORY_HOME/backup/. $JFROG_HOME/artifactory/var/backup/artifactory/
 
# Access backup (optional)
mkdir -p $JFROG_HOME/artifactory/var/backup/access/
cp -rp $ARTIFACTORY_HOME/access/data/. $JFROG_HOME/artifactory/var/backup/access/
 
# Replicator backup (optional)
mkdir -p $JFROG_HOME/artifactory/var/backup/replicator/
cp -rp $ARTIFACTORY_HOME/replicator/data/. $JFROG_HOME/artifactory/var/backup/replicator/
 
# Access logs (optional)
mkdir -p $JFROG_HOME/artifactory/var/log/archived/access/
cp -rp $ARTIFACTORY_HOME/access/logs/. $JFROG_HOME/artifactory/var/log/archived/access/
 
# Replicator logs (optional)
mkdir -p $JFROG_HOME/artifactory/var/log/archived/replicator/
cp -rp $ARTIFACTORY_HOME/replicator/logs/. $JFROG_HOME/artifactory/var/log/archived/replicator/
#Run the migration script with the same privileges as you have in your current Artifactory installation. 
#This script will copy over and translate your current configurations to the new configuration format, according to the new file system layout.

#The migration script only migrates configuration values. Any comments added to the configuration files in the Artifactory 6.x installation will not be migrated.

cd $JFROG_HOME/artifactory/app/bin
./migrate.sh
#When upgrading Artifactory using Linux Archive, you will need to verify that the copied directories and the copied content have the right owners.

#If you are using the default user:group, the owner will automatically be assigned artifactory:artifactory, and you will not need to take any further actions (the upgrade will use these by default).

#If, however, you are using a custom user:group, you will then need to go the Artifactory system.yaml file and update it with the custom user:group. You will then need to make sure that the directory has the same user and group.

#Check that the migration has completed successfully, by reviewing the following files:
## - migration log: $JFROG_HOME/artifactory/var/log/migration.log
#- system.yaml configuration: $JFROG_HOME/artifactory/var/etc/system.yaml
#   This newly created file will contain your current custom configurations in the new format.
#If Artifactory was installed as a service in previous version, install this version also as a service.

#When an earlier version is installed as a service, it is important to update the new one also as a service. Otherwise a restart of the server may lead to older version of Artifactory coming up.

cd $JFROG_HOME/artifactory/app/bin
./installService.sh
#Manage Artifactory.

$JFROG_HOME/artifactory/app/bin/artifactoryctl start
#Access Artifactory from your browser at: http://SERVER_HOSTNAME:8082/ui/. For example, on your local machine: http://localhost:8082/ui/

#If you had a reverse proxy or load balancer configured with your Artifactory 6.x, you will need to create a new reverse proxy configuration and update your reverse proxy settings.
#You can generate a new configuration template by accessing the upgraded Artifactory server UI (by default http://localhost:8082/ui/), navigate to 
#Administration > Artifactory > General > HTTP Settings adjust your Reverse Proxy Settings and generate a new configuration template. See more information about reverse proxy settings. 



#Check Artifactory Log.
#tail -f $JFROG_HOME/artifactory/var/log/console.log