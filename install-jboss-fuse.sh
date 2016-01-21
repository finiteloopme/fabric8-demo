#!/usr/bin/env bash

FUSE_ARTIFACT_ID=jboss-fuse-full
VERSION_JBOSS_FUSE=6.2.1.redhat-090
#VERSION_JBOSS_FUSE=6.2.0.redhat-133
MAVEN_REPO=http://origin-repository.jboss.org/nexus/content/groups/ea
#MAVEN_REPO=https://repository.jboss.org/nexus/content/groups/ea
#MAVEN_REPO=https://repo.fusesource.com/nexus/content/groups/public
# Lets fail fast if any command in this script does succeed.
set -e

# Install curl and jdk (we need the jdk devel version, because jar utility is available in it)
sudo yum -y install curl java-1.7.0-openjdk-devel

mkdir -p /opt/jboss
cd /opt/jboss

# Download the fuse artifact
echo "Downloading" ${MAVEN_REPO}/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${VERSION_JBOSS_FUSE}/${FUSE_ARTIFACT_ID}-${VERSION_JBOSS_FUSE}.zip
curl -O ${MAVEN_REPO}/org/jboss/fuse/${FUSE_ARTIFACT_ID}/${VERSION_JBOSS_FUSE}/${FUSE_ARTIFACT_ID}-${VERSION_JBOSS_FUSE}.zip
jar -xvf ${FUSE_ARTIFACT_ID}-${VERSION_JBOSS_FUSE}.zip
rm ${FUSE_ARTIFACT_ID}-${VERSION_JBOSS_FUSE}.zip
mv jboss-fuse-${VERSION_JBOSS_FUSE} ${FUSE_ARTIFACT_ID}
# assuming `whoami` results in cloud-user
chown -hR cloud-user ${FUSE_ARTIFACT_ID}
chmod 755 ${FUSE_ARTIFACT_ID}/bin/*

echo '
bind.address=0.0.0.0
'>> ${FUSE_ARTIFACT_ID}/etc/system.properties
echo '
admin=admin, admin, Operator, Maintainer, Deployer, Auditor, Administrator, SuperUser
' >> ${FUSE_ARTIFACT_ID}/etc/users.properties
echo '
jmxRole=admin
' >> ${FUSE_ARTIFACT_ID}/etc/org.apache.karaf.management.cfg
echo '
sshRole=admin
' >> ${FUSE_ARTIFACT_ID}/etc/org.apache.karaf.shell.cfg
