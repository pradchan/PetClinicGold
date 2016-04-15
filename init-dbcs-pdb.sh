#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: ${0} <db user> <db password> <ssh key file> <db server ip> [<PDB name>]";
  exit -1;
fi

appuser="petclinic"
apppassword="petclinic"
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

scp -i ${sshkey} database/create_user.sql  oracle@${ipaddress}:create_user.sql
scp -i ${sshkey} spring-petclinic/src/main/resources/db/oracle/initDB.sql  oracle@${ipaddress}:initDB.sql
scp -i ${sshkey} spring-petclinic/src/main/resources/db/oracle/populateDB.sql  oracle@${ipaddress}:populateDB.sql

ssh -i ${sshkey} oracle@${ipaddress} "cat create_user.sql | sqlplus ${dbuser}/${dbpassword}@${pdb}"
ssh -i ${sshkey} oracle@${ipaddress} "cat initDB.sql | sqlplus ${appuser}/${apppassword}@${pdb}"
ssh -i ${sshkey} oracle@${ipaddress} "cat populateDB.sql | sqlplus ${appuser}/${apppassword}@${pdb}"
