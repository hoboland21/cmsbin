#!/bin/sh

cd /db/export
### Setting up the mount for holding the database data  
export DATAMOUNT=$(pwd)
### Go over to the script directory
mail -s 'Mensa Beginning Transfer' jc.clark@modahealth.com "Exporting data from @HOSTNAME -  $(date)"
cd /home/db2inst1/cmsbin
./new_export.sh icmnlsdb 819
./new_export.sh rmdb 1208
./new_export.sh odsutils 819 
rm -fr /datadomain/export/*
mv /db/export/*    /datadomain/export 
