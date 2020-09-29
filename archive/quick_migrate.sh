#!/bin/bash

db2stop force
ipclean
db2start 



#db2 drop database ICMNLSDB
db2 drop database RMDB
#db2 drop database ODSUTILS
#db2 drop database ECMDB

#rm -fr /db/*

#db2 create db ICMNLSDB on /db
#db2 create db ODSUTILS on /db
db2 create db RMDB on /db
#db2 create db ECMDB on /db

#db2 connect to icmnlsdb
#db2 update db cfg using LOGARCHMETH1 DISK:/db/
#db2 connect to rmdb
#db2 update db cfg using LOGARCHMETH1 DISK:/db/
#db2 connect to odsutils
#db2 update db cfg using LOGARCHMETH1 DISK:/db/


#db2 connect to icmnlsdb
#db2 update db cfg using LOGFILSIZ 5000
#db2 update db cfg using LOGPRIMARY 50
#db2 update db cfg using LOGSECOND 206

db2 connect to rmdb
db2 update db cfg using LOGFILSIZ 5000
db2 update db cfg using LOGPRIMARY 50
db2 update db cfg using LOGSECOND 206

#db2 connect to odsutils
#db2 update db cfg using LOGFILSIZ 5000
#db2 update db cfg using LOGPRIMARY 50
#db2 update db cfg using LOGSECOND 206

#db2 connect to ecmdb
#db2 update db cfg using LOGFILSIZ 5000
#db2 update db cfg using LOGPRIMARY 50
#db2 update db cfg using LOGSECOND 206

db2stop force
ipclean
db2start 

#db2 connect to icmnlsdb
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMADMIN"'
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMCONCT"'

db2 connect to rmdb
db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMADMIN"'
db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS, SECADM ON DATABASE TO USER "RMADMIN"'

#db2 connect to odsutils
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMADMIN"'
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMCONCT"'


#db2 connect to ecmdb
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMADMIN"'
#db2 'GRANT CREATETAB, BINDADD, CONNECT, CREATE_NOT_FENCED_ROUTINE, IMPLICIT_SCHEMA, LOAD, DBADM, CREATE_EXTERNAL_ROUTINE, QUIESCE_CONNECT, ACCESSCTRL, DATAACCESS ON DATABASE TO USER "ICMCONCT"'


echo ==============================================================
echo DB2 Database setup complete 
echo ==============================================================

#mkdir /db/bkp_emptydb
		
#dbs=('ICMNLSDB' 'RMDB' 'ODSUTILS')
		
		

#for d in "${dbs[@]}"
#do
#	db2 connect to $d
#	db2 quiesce database immediate force connections
#	db2 connect reset
#	db2 backup database $d to /db/bkp_emptydb compress without prompting
#echo $d
#done


#!/bin/bash

DATAMOUNT=/cmdatalinux1/datatransfer

#find $DATAMOUNT -name '*.txt' -exec rm {} \;
#find $DATAMOUNT -name '*.msg' -exec rm {} \;
#find $DATAMOUNT -name 'LOAD.out' -exec rm {} \;


#	dbs=('rmdb' 'odsutils' 'icmnlsdb')
	dbs=('rmdb' )

# $d is database
# $t is table
		
run_tables() {
  d=$1
  TBLDIR="$DATAMOUNT/$d/tblspace"
  echo Executed look for $d

  db2 -tvf $DATAMOUNT/$d/look/$d.Look.sql > $DATAMOUNT/$d/look/$d-look.txt

  for t in $( cat "$TBLDIR/$d-dbtable.lst"  ); do
   echo In database : $d Moving Data To Tablespace $t
   cd "$TBLDIR/$t"
   db2move $d load >> ../$d.import.txt
  done
		
  echo $d Completed 
}

date
for b in "${dbs[@]}"
do
 run_tables $b   
done
date
