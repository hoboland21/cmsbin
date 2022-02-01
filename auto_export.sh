#!/bin/bash

cd /db/export
### Setting up the mount for holding the database data  
export DATAMOUNT=$(pwd)
### Go over to the script directory
XFR_START="$(date)"
echo $(date) Kicking off the job
exit
cd /home/db2inst1/cmsbin
./new_export.sh icmnlsdb 819
echo $(date) ICMNLSDB finished processing
./new_export.sh rmdb 1208
echo $(date) RMDB finished processing
./new_export.sh odsutils 819 
echo $(date) ODSUTILS finished processing
rm -fr /datadomain/export/*
echo $(date) Removed contents of the export directory
mv /db/export/*    /datadomain/export 
echo $(date) DB export contents have been moved to /datadomain
