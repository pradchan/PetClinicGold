#!/bin/bash
export JAVA_OPTS="-Djdbc.url=jdbc:oracle:thin:@${DBAAS_DEFAULT_CONNECT_DESCRIPTOR} -Djdbc.username=${DBAAS_USER_NAME} -Djdbc.password=${DBAAS_USER_PASSWORD}"
sh ./apache-tomcat-8.0.33/bin/catalina.sh run
