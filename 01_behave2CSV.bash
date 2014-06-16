#!/usr/bin/env bash

## 1. link in MEG
## 2. generate CSV files

MEGRAWDIR=/data/Luna1/MultiModal/MEG_Raw

scriptdir=$(cd $(dirname $0); pwd)
find $scriptdir/subjs/ -iname 'MEG_*_tc.mat' | while read mat; do

 # make sure we can match a subject id
 [[ ! $(basename $mat) =~ MEG_([0-9]{5})_([0-9]{8})_tc ]] && continue
 subjid=${BASH_REMATCH[1]}
 date=${BASH_REMATCH[2]}

 # output as the mat file but without the .mat
 fname=$(dirname $mat)/$(basename $mat .mat)

 fifLnkDir=$(dirname $mat)/../MEG/
 [ ! -d $fifLnkDir ] && mkdir $fifLnkDir 

 find $MEGRAWDIR/${subjid}_${date} -type f -iname '*run*_raw.fif' | while read fif; do
   [[ ! $(basename $fif) =~ [Rr]un([1-8]) ]] && continue
   run=$(echo ${BASH_REMATCH[1]}|tr 'R' 'r')

   # link
   [ ! -r $fifLnkDir/$(basename $fif) ] && ln -s $fif $fifLnkDir/

   echo $subjid $date $run $fif

   output=${fname}_$run.csv
   eveout=${fname}_$run.eve
   [ -r  $output -a -r $eveout ] && echo "skipping $output" && continue
   $scriptdir/timing.py -s ${subjid}_${date} -f $fif -m $mat -b $run -o $output -e $eveout

 done

done
