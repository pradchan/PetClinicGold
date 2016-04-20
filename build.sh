#!/bin/bash

if [ ! -r mvn/settings-security.xml ] || [ ! -r mvn/settings.xml ]; then
  echo "ERROR: Maven settings and security files not found.  To resolve run setup-mvn-security.sh."
else
  mvn -Dsettings.security=mvn/settings-security.xml -s mvn/settings.xml clean package
fi
