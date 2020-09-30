exit

	DB2 User and Groups
	
groupadd db2iadm1
groupadd db2fadm1
groupadd dasadm1

Create users for each group:

useradd  -g db2iadm1 -m -d /home/db2inst1 db2inst1 
useradd  -g db2fadm1 -m -d /home/db2fenc1 db2fenc1 
useradd  -g dasadm1 -m -d /home/dasusr1 dasusr1

passwd db2inst1
passwd db2fenc1
passwd dasusr1



Content Manager User and Groups

groupadd ibcmgrp
groupadd icmcmgrp

useradd -g  ibmcmgrp   -G  db2iadm1                       rmadmin
useradd -g  ibmcmgrp   -G  db2iadm1,icmcmgrp              icmconct
useradd -g  ibmcmgrp   -G  icmcmgrp                       ibmcmadm
useradd -g  ibmcmgrp   -G  db2iadm1                       icmadmin
useradd -g  ibmcmgrp   -G  db2iadm1                       ecmadmin