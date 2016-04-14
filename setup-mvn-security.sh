#!/bin/bash

# The master password is used to encrypt and decrypt the user password--hard wire for this sample.
master_password="MasterPassword"

echo -n Enter oracle.com User Id:
read oraclecom_userid

echo -n Enter oracle.com Password:
read -s oraclecom_password

# Encrypt the master password and put it into settings-security.xml
enc_master_password=`mvn --encrypt-master-password ${master_password}`
sed -e "s#MASTER_PASSWORD#${enc_master_password}#" < mvn/settings-security.template > mvn/settings-security.xml

# Encrypt the user password and put it into settings.xml
cwd=`pwd`
enc_oraclecom_password=`mvn -Dsettings.security=${cwd}/mvn/settings-security.xml --encrypt-password ${oraclecom_password}`
echo
sed -e "s#USER_ID#${oraclecom_userid}#" -e "s#USER_PASSWORD#${enc_oraclecom_password}#" < mvn/settings.template > mvn/settings.xml

echo "Maven setting.xml and settings-security.xml created."
