#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: ${0} <db user> <db password> <ssh key file> <db server ip> [<PDB name>]";
  exit -1;
fi

dbuser=${1}
dbpassword=${2}
sshkey=${3}
ipaddress=${4}
#Default PDB to PDB1 if not specified
if [ -z "$5" ]; then
   pdb="PDB1";
else
  pdb=${5};
fi

scp -i ${sshkey} database/create_user.sh   oracle@${ipaddress}:create_user.sh
scp -i ${sshkey} database/create_user.sql  oracle@${ipaddress}:create_user.sql
ssh -i ${sshkey} oracle@${ipaddress} "sh create_user.sh ${dbuser} ${dbpassword} ${pdb}"
