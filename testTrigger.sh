#!/bin/bash

SOURCEDATA=/datadomain/DB2/backup/AIX2Linux/MO3/datatransfer
#TARGETDATA=/home/db2inst1/datatransfer

TARGETDATA=/filetransfer/db_exp/datatransfer
TBLDIR="$TARGETDATA/tblspace"

dbs=('icmnlsdb' 'rmdb' 'odsutils')

# $d is database
# $t is table
		
for d in "${dbs[@]}"
do
  echo Executed look for $d

 db2 connect to $d
  echo executing Foreign Keys for $d
  db2 -tvf $TARGETDATA/$d/look/$d.Foreign.sql > $TARGETDATA/$d/look/$d-Foreign.txt
 
  echo executing Triggers for $d
  db2 -tvf $TARGETDATA/$d/look/$d.Triggers.sql > $TARGETDATA/$d/look/$d-Triggers.txt
		
  echo $d Completed 
done
