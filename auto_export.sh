#!/bin/sh

cd /db/export
### Setting up the mount for holding the database data  
export DATAMOUNT=$(pwd)
### Go over to the script directory
XFR_START="$(date)"
mail -s 'Mensa Transfer' jc.clark@modahealth.com "Exporting data from @HOSTNAME -  $(date)"
cd /home/db2inst1/cmsbin
./new_export.sh icmnlsdb 819
mail -s 'Mensa Transfer' jc.clark@modahealth.com "ICMNLSDB DB has completed export -  $(date)"
./new_export.sh rmdb 1208
mail -s 'Mensa Transfer' jc.clark@modahealth.com "RMDB DB has completed export -  $(date)"
./new_export.sh odsutils 819 
mail -s 'Mensa Transfer' jc.clark@modahealth.com "ODSUTILS DB Has completed export -  $(date)"
rm -fr /datadomain/export/*
mv /db/export/*    /datadomain/export 
mail -s 'Mensa Transfer' jc.clark@modahealth.com "Files have been moved to /datadomain/export - JOB Complete -  $XFR_START -> $(date)"
