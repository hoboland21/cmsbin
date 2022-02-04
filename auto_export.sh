#!/bin/bash
. /home/db2inst1/.profile

cd /datadomain/export

rm -fr /datadomain/export/*

echo $(date) Removed contents of the export directory

### Setting up the mount for holding the database data
export DATAMOUNT=$(pwd)
### Go over to the script directory
echo $(date) Kicking off the job
cd /home/db2inst1/cmsbin
./new_export.sh icmnlsdb 819
echo $(date) ICMNLSDB finished processing

./new_export.sh rmdb 1208
echo $(date) RMDB finished processing

./new_export.sh odsutils 819
echo $(date) ODSUTILS finished processing
touch /datadomain/export/EXPORTCOMPLETE
echo $(date) Export from DB2 has finished
echo ====================================
