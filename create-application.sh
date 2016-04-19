#!/bin/sh

# ________REQUIRED INPUT PARAMETERS_________
export ID_DOMAIN=$1
export USER_ID=$2
export USER_PASSWORD=$3
export APP_NAME="TomcatPetClinic"

export RUNTIME="java"
export APAAS_HOST=apaas.us.oraclecloud.com

if [ -z "${ID_DOMAIN}" ] || [ -z "$USER_ID" ] || [ -z "$USER_PASSWORD" ]; then
  echo "usage: ${0} <id domain> <user id> <user password>";
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
    -F "deployment=@deployment.json" \
    https://${APAAS_HOST}/paas/service/apaas/api/v1.1/apps/${ID_DOMAIN}
fi
echo '\n[info] Complete\n'
