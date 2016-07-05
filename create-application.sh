#!/bin/sh

# ________REQUIRED INPUT PARAMETERS_________
export ID_DOMAIN=$1
#export USER_ID="gse-admin_ww@oracle.com"
#export USER_PASSWORD="ZAQ!2wsx"
export APP_NAME="TomcatPetClinic"

export RUNTIME="java"
export APAAS_HOST=apaas.us.oraclecloud.com

export USER_ID=$(curl -s -X GET -H 'X-Oracle-Authorization: Basic Z3NlLWRldm9wc193d0BvcmFjbGUuY29tOjVjWmJzWkxuMQ==' 'https://adsweb.oracleads.com/apex/adsweb/parameters/democloud_admin_opc_email' | jq '.items[].value' | tr -d '"')
export USER_PASSWORD=$(curl -s -X GET -H 'X-Oracle-Authorization: Basic Z3NlLWRldm9wc193d0BvcmFjbGUuY29tOjVjWmJzWkxuMQ==' 'https://adsweb.oracleads.com/apex/adsweb/parameters/democloud_admin_opc_password' | jq '.items[].value' | tr -d '"')

if [ -z "${ID_DOMAIN}" ] || [ -z "$USER_ID" ] || [ -z "$USER_PASSWORD" ]; then
  echo "usage: ${0} <id domain> ";
  exit -1;
fi


# See if application exists
let httpCode=`curl -i -X GET  \
  -u ${USER_ID}:${USER_PASSWORD} \
  -H "X-ID-TENANT-NAME:${ID_DOMAIN}" \
  -H "Content-Type: multipart/form-data" \
  -sL -w "%{http_code}" \
  https://${APAAS_HOST}/paas/service/apaas/api/v1.1/apps/${ID_DOMAIN}/${APP_NAME} \
  -o /dev/null`

# If application exists...
if [ $httpCode == 200 ]
then
  # Update application with deployment.json
  echo '\n[info] Updating application...\n'
  curl -i -X PUT  \
    -u ${USER_ID}:${USER_PASSWORD} \
    -H "X-ID-TENANT-NAME:${ID_DOMAIN}" \
    -H "Content-Type: multipart/form-data" \
    -F "deployment=@deployment.json" \
    https://${APAAS_HOST}/paas/service/apaas/api/v1.1/apps/${ID_DOMAIN}/${APP_NAME}
else
  # Create application with deployment.json
  echo '\n[info] Creating application...\n'
  curl -i -X POST  \
    -u ${USER_ID}:${USER_PASSWORD} \
    -H "X-ID-TENANT-NAME:${ID_DOMAIN}" \
    -H "Content-Type: multipart/form-data" \
    -F "name=${APP_NAME}" \
    -F "runtime=${RUNTIME}" \
    -F "subscription=Hourly" \
    -F "deployment=@/storage/cloud/bundles/appdev/refresh/jcode/apaas/petclinic/deployment.json" \
    https://${APAAS_HOST}/paas/service/apaas/api/v1.1/apps/${ID_DOMAIN}
fi
echo '\n[info] Complete\n'
