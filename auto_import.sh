#!/bin/bash

echo $(date) Beginning Import of Mensa Data set

. /home/db2inst1/.bashrc


export PATH=/home/db2inst1/cmsbin:$PATH
export DATAMOUNT=/datadomain/export-gold/

cd $DATAMOUNT 

echo $(date) creating backup data image
echo $PATH

rm -fr /datadomain/export-gold/*
cp -r  /datadomain/export/* /datadomain/export-gold/


echo $(date) Running varchar.py on icmnmlsdb and odsutils

cd $DATAMOUNT/icmnlsdb/look
varchar.py icmnlsdb.Look.sql
 
cd $DATAMOUNT/odsutils/look
varchar.py odsutils.Look.sql

echo $(date) Executing new_migrate.sh 

new_migrate.sh

echo $(date) Executing final_phase.sh 

final_phase.sh

echo $(date) Import complete - please run Content Manager configuration.
