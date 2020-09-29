#!/bin/bash


    db2 connect to ICMNLSDB
    db2 "update ICMADMIN.ICMSTRESOURCEMGR set INETADDR='rh-cm-stg.pdx.odshp.com' where RMCODE=1"
    db2 terminate

    db2 connect to RMDB
    db2 "update RMADMIN.RMSERVER set SVR_HOSTNAME='rh-cm-stg.pdx.odshp.com' where SVR_SERVERID=1"
    db2 "update RMADMIN.RMSERVER set SVR_SERPLATFORM='Linux'"
    db2 terminate
    
db2rbind icmnlsdb -l /tmp/db2rbind1.out all 
db2rbind rmdb -l /tmp/db2rbind2.out all 
db2rbind odsutils -l /tmp/db2rbind3.out all 




dbs=('rmdb' 'odsutils' 'icmnlsdb')

run_integration() {

  for b in "${dbs[@]}"
   do
    db2 connect to $b	
   db2 +o "connect to $b" 
   db2 -xn "select TABSCHEMA,TABNAME from syscat.tabconst where TYPE='F'" | awk '{print $1"."$2}' |  sort| uniq    > tmplist 
	

    for t in $( cat tmplist )
	do
	db2 -v "SET INTEGRITY for $t immediate checked"
	echo  I:wqntegration $t
    done  		
done




#    db2 -xn "select  TBCREATOR, TBNAME, NAME from sysibm.syscolumns where IDENTITY = 'Y' " | awk '{print $1, $2, $3 }' | sort | uniq > ResetGenIDs 2>&1
 
#while IFS= read -r line
#do
 # echo -- $line --
 # TBCREATOR=$( echo $line | awk '{ print $1 }' )
 # TBNAME=$( echo $line | awk '{ print $2 }')
 # NAME=$( echo $line | awk '{ print $3 }')

 # GEN=`db2 +o  "connect to $b " ;  db2 -xn "select MAX(${NAME})+1 from $TBCREATOR.$TBNAME"  | awk '{print $1}'`

#echo List  $TBCREATOR -- $TBNAME -- $NAME -- $GEN

#sleep 2

# db2 +o  "connect to TESTLIVE"
# db2 -v  "ALTER TABLE EXTERNAL_DATA_STAGE.${TBL} ALTER COLUMN ${COL} RESTART WITH ${GEN}"
#done < ResetGenIDs


 #  done

}

#  tbl_lst=`cat /home/db2inst1/DB2move/DBrefresh-TBL.lst | awk ' { print $1 }'`
#db2 -v  "connect to TESTLIVE" > ${JOBLOG} 2>&1
#for TBL in ${tbl_lst}; do
# db2 -v "SET INTEGRITY FOR EXTERNAL_DATA_STAGE.$TBL immediate checked" >> ${JOBLOG} 2>&1
#done
#db2 -v "terminate"

#tbl_lst=` db2 +o "connect to TESTLIVE" ; db2 -xn "select TABNAME from syscat.tabconst  where tabschema='EXTERNAL_DATA_STAGE' and TYPE='F'" | awk '{print $1}' | sort | uniq` 

run_integration




