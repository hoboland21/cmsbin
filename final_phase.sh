#!/bin/bash

db=('rmdb'  'icmnlsdb' 'odsutils')

server_update() {
   db2 connect to ICMNLSDB
   db2 "update ICMADMIN.ICMSTRESOURCEMGR set INETADDR='cm-sbx' where RMCODE=1"
   db2 terminate

   db2 connect to RMDB
   db2 "update RMADMIN.RMSERVER set SVR_HOSTNAME='cm-sbx' where SVR_SERVERID=1"
   db2 "update RMADMIN.RMSERVER set SVR_SERPLATFORM='Linux'"
   db2 terminate

}

db_binding() {

   db2rbind icmnlsdb -l /tmp/db2rbind1.out all 
   db2rbind rmdb -l /tmp/db2rbind2.out all 
   db2rbind odsutils -l /tmp/db2rbind3.out all 
}

generate_fix() {
   echo START > $DATAMOUNT/tmp/final_phase.log
   date >> $DATAMOUNT/tmp/final_phase.log

   for d in "${db[@]}"
      do
         db2 connect to $d
         db2 -xn "select  TBCREATOR, TBNAME, NAME from sysibm.syscolumns where IDENTITY = 'Y' " | awk '{print $1, $2, $3 }' | sort | uniq > ResetGenIDs 2>&1
         
         while IFS= read -r line
         do
               TBCREATOR=$( echo $line | awk '{ print $1 }' )
               TBNAME=$( echo $line | awk '{ print $2 }')
               NAME=$( echo $line | awk '{ print $3 }')
               
               MTABLE=$(grep \"$TBNAME\"  $DATAMOUNT/$d/data/db2move.lst | awk 'BEGIN { FS="!" }{print $3 }'  )
               echo $TBCREATOR $TBNAME $NAME $MTABLE
               db2 -x "load from $DATAMOUNT/$d/data/$MTABLE of ixf modified by identityoverride replace into $TBCREATOR.$TBNAME " >> $DATAMOUNT/tmp/final_phase.log
               db2 -x "SET INTEGRITY FOR $TBCREATOR.$TBNAME  IMMEDIATE CHECKED" >> $DATAMOUNT/tmp/final_phase.log
         done < ResetGenIDs
   done
   date >> $DATAMOUNT/tmp/final_phase.log
}

tablespaces() {
   for d in "${db[@]}"
      do
         db2 connect to $d
         echo Doing $d 

         for x in $(db2 -x "select TBSPACE from sysibm.SYSTABLESPACES")
         do
         db2 -x "ALTER TABLESPACE $x MANAGED BY AUTOMATIC STORAGE"
         done
   done
}


tablespaces
exit 







