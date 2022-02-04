#!/usr/bin/bash
. /home/db2inst1/.profile

db2stop force
ipclean
db2start


# Lets use some command line to make it more user friendly 

if [ ! $DATAMOUNT ] ; then
	echo Where is your DATAMOUNT ?
	exit
fi

if [ ! -d $DATAMOUNT ]; then
	echo $DATAMOUNT is not a directory
	exit
fi	
echo 
echo ------------------------------------
echo the DATAMOUNT is $DATAMOUNT
echo


if [ $# -lt 2 ] ; then
echo 'Not enough arguments' 
echo
echo This script requires the Database name  and Codepage 819 or 1208 as an argument
echo
echo
exit
fi

export DB2CODEPAGE=$2

db2 connect to $1
if [ $? != 0 ]  ;then
	echo No Connection could be established WITH $1
	exit 
fi
	echo Good connect $1


CURRDB=$1

#ESTMOUNT="/datadomain4/DB2/backup/AIX2Linux/MO3"
BASEMOUNT="$DATAMOUNT/$CURRDB"

if [ ! -d $BASEMOUNT ] ; then
	mkdir -p $BASEMOUNT
fi

echo =============================================
echo Deleting files currently on mount?
echo =============================================
rm -rf $BASEMOUNT/*
echo
echo Creating Image Directory Structure
echo
mkdir -p $BASEMOUNT/data
mkdir -p $BASEMOUNT/look


START_PWD=$(pwd) 
cd $BASEMOUNT/look

#db2look -d $CURRDB  -e -a -x -l -o $CURRDB.Look.sql
db2look -d $CURRDB -a -e -m -f -x -l -o $CURRDB.Look.sql


echo Time Mark Start $CURRDB $(date) 

cd $BASEMOUNT/data
db2move $1 export  >> ../$1.txt


cd $START_PWD

#DESTMOUNT=/datadomain4/DB2/backup/AIX2Linux/MO3
#echo moving data to $DESTMOUNT/datatransfer
#rm -r $DESTMOUNT/datatransfer
#cp -r $HOME/datatransfer $DESTMOUNT/
echo Time Mark End $CURRDB $(date) 
