#!/bin/sh

if [ -z "$1" ] && [ -z "$2" ]; then
  echo "usage: ${0} <ssh key file> <database server ip>";
  exit -1;
fi

SSH_KEY=$1
DB_IP=$2

echo "Opening SSH port forward from localhost:1521 to ${DB_IP}:1521"

ssh -i ${SSH_KEY} opc@${DB_IP} -L 1521:${DB_IP}:1521 -N
