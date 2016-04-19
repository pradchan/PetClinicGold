#!/bin/sh

TOMCAT_VERSION=8.0.33
TOMCAT_DIST=apache-tomcat-${TOMCAT_VERSION}

# Move petclinic.war to Tomcat webapps folder
mv spring-petclinic/target/petclinic.war ${TOMCAT_DIST}/webapps/ROOT.war

# Create application archive with Tomcat (with petclinic war) and manifest.json
zip -r tomcat-petclinic-dist.zip manifest.json start.sh ${TOMCAT_DIST}
