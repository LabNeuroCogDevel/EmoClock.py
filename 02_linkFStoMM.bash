#!/usr/bin/env bash

# link FS folders into Clock subject

# where we want  new FSdir to be
origdir="/data/Luna1/MultiModal/FS_Subjects/"
newdir="/data/Luna1/MultiModal/Clock/"
mridir="/data/Luna1/Raw/MultiModal/"

for subjdir in $newdir/*/; do 
 subj=$(basename $subjdir)
 # grab the newest (by subj_date ) that matches this subj
 subjFSdir=$(ls -d $origdir/$subj* 2>/dev/null|sort -nr|sed 1q)

 if [ -z "$subjFSdir" ]; then 
   echo "NO FS for $subj" 
   subjMRI=$(ls -d $mridir/$subj* 2>/dev/null|sort -nr|sed 1q)
   echo -e "\tmaybe\n\tUSETMUX=1 ~/src/freesurfersearcher-general/surfOne.sh -t MM -i $(basename $subjMRI)"
   continue
 fi

 for fsitem in $subjFSdir/*; do
  newloc="$newdir/$(basename $fsitem)"
  [ -r $newloc ] && continue
  ln -s $fsitem $newloc
 done

done
