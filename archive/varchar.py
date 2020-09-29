#!/usr/bin/python3
import re
import sys

if len(sys.argv) > 1:
   
   p = re.compile("(VARCHAR)\((\d+)\)")
   src = open(sys.argv[1],'r')
   dest = open(f'{sys.argv[1]}.res','w')

   line = src.readline()
   while line :
#     print(line.rstrip()) 
      result = p.finditer(line)
      new_line = line
      for x in result :
         new_val = str(int(x.group(2))*2)
         old_vc = x.group(0)
         new_vc = f'VARCHAR({new_val})'
         new_line = line.replace(old_vc,new_vc,1)
         
         
      dest.write(new_line)

      line = src.readline()

    # We can check that the file has been automatically closed.
   src.close()
   dest.close()
   

#    result = p.finditer(read_data)
#    for x in result :
#        new_val = str(int(x.group(2))*2)
#        print(x.group(0), x.group(2), f'varchar({new_val})')
