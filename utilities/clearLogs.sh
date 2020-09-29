#!/bin/bash
for d in 1 2 3 4 ; do 
	 x="/db/db2inst1/NODE0000/SQL0000$d/LOGSTREAM0000/*"
   find $x -cmin +2 -exec rm {} +
#   ls "$2" 2> /dev/null > /dev/null 	
#	if [ $? == 0 ] ; then
#	fi

done
