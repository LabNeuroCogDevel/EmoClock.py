#!/usr/bin/env bash

echo "# Get Behave data"
scriptdir=$(cd $(dirname $0); pwd)

## TODO: mount on wallace and save this struggle
# find all the behavior mat files form the clock task on B (mounted on reese)
ssh lncd@reese 'find /mnt/B/bea_res/Data/Tasks/EmoClockMEG/ -type f -iname "MEG*_tc.mat"'|tee $scriptdir/log/matlist.txt |while read mat; do
  # does this have a luna id?
  [[ ! $mat =~ [0-9]{5}_[0-9]{8} ]] && echo skipping $mat && continue
  subjid=$BASH_REMATCH

  # create the behavior directory
  bedir=$scriptdir/subjs/$subjid/behavior
  [ ! -d $bedir ] && mkdir -p $bedir

  #[ -r $bedir/$(basename $mat) ] && echo "already have $(basename $mat) in $bedir" && continue
  [ -r $bedir/$(basename $mat) ] && continue

  # grab it (with rsync)
  rsync -avhi lncd@reese:$mat  $bedir/

done


awk '($3==0){print $1 "_" $2}' $scriptdir/txt/subj_date_drop_note.txt |sort| while read ld; do [ -d $scriptdir/subjs/$ld ] || echo "missing .mat behave for $ld"; done
