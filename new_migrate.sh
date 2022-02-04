#!/bin/bash


#################################################
# Establish Environment Variables
#################################################
dbs=('icmnlsdb' 'rmdb' 'odsutils')

#------------------------------------------------------ 
# Lets use some command line to make it more user friendly
# set up the sbin directory to catchthe commands
#------------------------------------------------------ 
old_path=$PATH
#export PATH=/filetransfer/contentManager/sbin:$PATH


#==============================================================
# Functions
#==============================================================
# stage Data - separate Triggers and Foreign Key definitions into 
# their own file for separate processing
#==============================================================
stageData () {
#==============================================================
   # Argument is $1  -  Database N 
  echo Staging data separating Foreign Keys and Triggers 
  d=$1
  LOOKDIR="$DATAMOUNT/$d/look"

	if [ ! -f $LOOKDIR/$d.Look.Triggers.sql ] ; then
    echo Extracting $d Triggers
    sed -n '/-- DDL Statements for Triggers/,/^-- /p' $LOOKDIR/$d.Look.sql > $LOOKDIR/$d.Look.Triggers.sql
    sed -in '/-- DDL Statements for Triggers/,/^-- /d' $LOOKDIR/$d.Look.sql  
  fi

	if [ ! -f $LOOKDIR/$d.Look.Foreign.sql ] ; then
    echo Extracting $d Foreign Keys
    sed -n '/-- DDL Statements for Foreign Keys/,/^---\+$/p' $LOOKDIR/$d.Look.sql  > $LOOKDIR/$d.Look.Foreign.sql
    sed -in '/-- DDL Statements for Foreign Keys/,/^---\+$/d' $LOOKDIR/$d.Look.sql
  fi
   cd $DATAMOUNT
}
#==============================================================
# This is the main import function - executes the look and 
# moves the data in 
#==============================================================
run_data() {
#==============================================================
   # Argument is $1  -  Database Name
  d=$1
  DATADIR="$DATAMOUNT/$d/data"
  LOOKDIR="$DATAMOUNT/$d/look"

  # check for tmp directory

  if [ ! -d $DATAMOUNT/tmp ] ; then
    mkdir -p $DATAMOUNT/tmp
  fi

  #
  # Database Structure is being created here
  # 
  echo Executing look for $d
  db2 connect to $d
  db2 -tvf $LOOKDIR/$d.Look.sql > $LOOKDIR/$d-look.txt
  echo Executing Foreign Keys for $d
  db2 connect to $d
  db2 -tvf $LOOKDIR/$d.Look.Foreign.sql > $LOOKDIR/$d-Foreign.txt
  db2 connect to $d
  echo executing Triggers for $d
  db2 -tvf $LOOKDIR/$d.Look.Triggers.sql > $LOOKDIR/$d-Triggers.txt
  db2 connect to $d


  echo executing Integrity OFF
  db2 -xn "select tabschema,tabname from syscat.tables   order by PARENTS ASC" | awk '{print $1"."$2}'  > $DATAMOUNT/tmp/all-tables-$d.txt 

  while read line ; do
    echo setting integrity for $line  OFF
    db2 -xn "SET INTEGRITY FOR $line  OFF"  
  done < $DATAMOUNT/tmp/all-tables-$d.txt
      
 		
  echo In database : $d Moving Data 
  cd "$DATADIR"
  db2move $d load >> $d.import.txt

  db2 connect to $d
  db2 -xn "select tabschema,tabname from syscat.tables  where ACCESS_MODE != 'F' or STATUS != 'N' order by PARENTS ASC" | awk '{print $1"."$2}'  > $DATAMOUNT/tmp/all-tables-$d.txt 

  for i in {1..5} ;  do 
    while read line ; do
          echo setting integrity for $line  ON
          db2 -xn "SET INTEGRITY FOR $line  IMMEDIATE CHECKED"  
        done < $DATAMOUNT/tmp/all-tables-$d.txt
  sleep 2 
  done
  echo $d Completed 
  cd $DATAMOUNT
}

####################################################################
# MAIN SCRIPT EXECUTION 
####################################################################
. /home/db2inst1/.profile

echo Job Start
date
echo ------------------------------------
echo DB2 Content Manager Migration Script
echo ====================================

if [ ! $DATAMOUNT ] ; then
	echo Where is your DATAMOUNT ?
	exit
fi

if [ ! -d $DATAMOUNT ]; then
	echo $DATAMOUNT is not a directory
	exit
fi	
echo ------------------------------------
echo the DATAMOUNT is $DATAMOUNT
echo
#====================================
echo Clearing and Initializing Database 
echo
find $DATAMOUNT -name '*.txt' -exec rm {} \;
find $DATAMOUNT -name '*.msg' -exec rm {} \;
find $DATAMOUNT -name 'LOAD.out' -exec rm {} \;

# external script mkDB removes all databases and
# recreates them in the /db directory

db2start 
#
mkDB
# 
db2start

echo Setting Admin authorities on
echo Setting default codepage to 1208

export DB2CODEPAGE=1208
db2set DB2_RESTORE_GRANT_ADMIN_AUTHORITIES=ON

echo =========================
echo  Starting the Run
date
echo =========================

for d in "${dbs[@]}"
do
  db2 connect to $d
  stageData $d
  run_data $d   
  db2 terminate

  echo $d Finished 
  date
  echo =====================

done
# -------------------------------------
# external script final phase must be done now
# -------------------------------------
echo execute final_phase.sh to finish 
echo
echo Then run Content Manager Configuration to register
echo changed Databases
# -------------------------------------
echo =====================
echo Job Complete
date
echo =====================
export PATH=$old_path
