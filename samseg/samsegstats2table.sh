#!/bin/bash
# Run script from SUBJECTS_DIR
#Reads all files found called samseg.stats aand combines into a single files
#Must provide a list of files e.g. by running
#find $PWD -name samseg.stats | sort > all_samsegstatfiles.txt
#The gather all stats by
#samsegstats2table.sh all_samsegstatfiles.txt

#Get a list of files

infiles=$1

if [ ! -f "$infiles" ]; then

  echo File "$infiles" not found. Exiting.
  echo  
  exit
  
fi

outfile=samsegstats.txt

file1=`head "$infiles" -n 1`

#Get the header of the first file
headings=`cat "$file1" | awk -F' ' '{print $3}' | sed 's/,//'`

echo $headings > "$outfile"

while read line; do

  stats=`cat "$line" | awk -F', ' '{print $2}'`
  #echo Stats are
  echo $stats
  
done < "$infiles" >> "$outfile"