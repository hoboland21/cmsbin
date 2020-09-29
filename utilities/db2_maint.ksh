#!/bin/ksh
db2pw=$1

# source teh db2 profile so db2 commands work.
. /opt/IBM/db2cmv8/bin/cmbenv81.sh
. /home/db2inst1/sqllib/db2profile

if [ -z "$db2pw" ]; then
	print 'Password Required try again'
	exit 1
fi

echo start time = `date`

# ODSUTILS Maintenance
db2 connect to odsutils user db2inst1 using $db2pw
if (( $?==0 ))
then
	echo "connected to DB2 successfull"
else
	echo "connection failed"
	exit 2
fi
mkdir -p /home/db2inst1/maint/maint_logs/previous
mkdir -p /home/db2inst1/maint/maint_logs/current

rm -r /home/db2inst1/maint/maint_logs/previous/*
mv /home/db2inst1/maint/maint_logs/current/* /home/db2inst1/maint/maint_logs/previous
#db2 reorgchk current statistics on table all > odsutils.current.before.reorgchk.txt
db2 reorgchk update statistics on table all > /home/db2inst1/maint/maint_logs/current/odsutils.update.reorgchk.log

db2 -x "select 'reorg indexes all for table APPDATA.' CONCAT tabname CONCAT ';' \
from syscat.tables where \
tabschema = 'APPDATA' and TYPE = 'T'" > /home/db2inst1/maint/maint_logs/current/odsutils.reorg.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/odsutils.reorg.sql > /home/db2inst1/maint/maint_logs/current/odsutils.reorg.log

db2 -x "select 'runstats on table APPDATA.' CONCAT tabname CONCAT ';' \
from syscat.tables where
tabschema = 'APPDATA' and type = 'T'" > /home/db2inst1/maint/maint_logs/current/odsutils.runstat.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/odsutils.runstat.sql > /home/db2inst1/maint/maint_logs/current/odsutils.runstat.log

db2rbind odsutils -l /home/db2inst1/maint/maint_logs/current/odsutils.rbind.log all -u db2inst1 -p $db2pw
db2 reorgchk current statistics on table all > /home/db2inst1/maint/maint_logs/current/odsutils.current.after.reorgchk.txt

db2 terminate

echo end time = `date`

# RMDB Maintenance
db2 connect to rmdb user db2inst1 using $db2pw
#db2 reorgchk current statistics on table all > rmdb.current.before.reorgchk.txt

db2 reorgchk update statistics on table all > /home/db2inst1/maint/maint_logs/current/rmdb.reorgchk.log

db2 -x "select 'reorg indexes all for table RMADMIN.' CONCAT tabname CONCAT ';' \
from syscat.tables where \
tabschema = 'RMADMIN' and TYPE = 'T'" > /home/db2inst1/maint/maint_logs/current/rmdb.reorg.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/rmdb.reorg.sql > /home/db2inst1/maint/maint_logs/current/rmdb.reorg.log

db2 -x "select 'runstats on table RMADMIN.' CONCAT tabname CONCAT ';' \
from syscat.tables where
tabschema = 'RMADMIN' and type = 'T'" > /home/db2inst1/maint/maint_logs/current/rmdb.runstat.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/rmdb.runstat.sql > /home/db2inst1/maint/maint_logs/current/rmdb.runstat.log

db2rbind rmdb -l /home/db2inst1/maint/maint_logs/current/rmdb.rbind.log all -u db2inst1 -p $db2pw
db2 reorgchk current statistics on table all > /home/db2inst1/maint/maint_logs/current/rmdb.current.after.reorgchk.txt


db2 terminate

echo end time = `date`


# ICMNLSDB Maintenance
db2 connect to icmnlsdb user db2inst1 using $db2pw
#db2 reorgchk current statistics on table all > /home/db2inst1/maint/maint_logs/current/icmnlsdb.current.before.reorgchk.txt
db2 reorgchk update statistics on table all > /home/db2inst1/maint/maint_logs/current/icmnlsdb.update.reorgchk.log

db2 -x "select 'reorg indexes all for table ICMADMIN.' CONCAT tabname CONCAT ';' \
from syscat.tables where \
tabschema = 'ICMADMIN' and TYPE = 'T'" > /home/db2inst1/maint/maint_logs/current/icmnlsdb.reorg.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/icmnlsdb.reorg.sql > /home/db2inst1/maint/maint_logs/current/icmnlsdb.reorg.log

db2 -x "select 'runstats on table ICMADMIN.' CONCAT tabname CONCAT ';' \
from syscat.tables where
tabschema = 'ICMADMIN' and type = 'T'" > /home/db2inst1/maint/maint_logs/current/icmnlsdb.runstat.sql

db2 -tvf /home/db2inst1/maint/maint_logs/current/icmnlsdb.runstat.sql > /home/db2inst1/maint/maint_logs/current/icmnlsdb.runstat.log

db2rbind icmnlsdb -l /home/db2inst1/maint/maint_logs/current/icmnlsdb.rbind.log all -u db2inst1 -p $db2pw
db2 reorgchk current statistics on table all > /home/db2inst1/maint/maint_logs/current/icmnlsdb.current.after.reorgchk.txt

db2 terminate

echo end time = `date`
cd /home/db2inst1/maint/maint_logs/current/
echo "----------------------------    Another ERROR Check   ------------------------------"
echo ""
grep -i error *.log
grep -i error *.txt
grep -i fail *.log
grep -i fail *.txt
grep -i cannot *.log
grep -i cannot *.txt
echo ""
echo "----------------------------    End Last Error Check   -----------------------------" 
exit;
