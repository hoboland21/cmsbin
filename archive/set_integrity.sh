 
 
 
 
 tab_list=`db2 connect to icmnlsdb; db2 -v "select char(tabschema,20),char(tabname,70) from syscat.tables"  | awk '{print $1"."$2}'` 

 echo -- $tab_list 
:
 for x in ${tab_list} ; do
 echo This is a table $x

done 

