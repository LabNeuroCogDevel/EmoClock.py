#!/usr/bin/env bash

# run  maxfilter  and ICA on those who have all bad channel txt files
CLOCKDIR="/data/Luna1/Multimodal/Clock"
scriptdir=$(cd $(dirname $0);pwd)

source $scriptdir/funcs.bash
# give function testnoproc

# for each subject
cd FinalDataDir;
for s in 1*/; do
  s=$(basename $s) # remove trailing /
  echo "## $s"

  # do we need to do anything?
  numICA=$(ls $CLOCKDIR/${s}/MEG/${s}_clock_run*_dn_ds_sss_raw.fif 2>/dev/null|wc -l )
  [ $numICA -eq 8 ] && echo "already have maxfilter and ICA for $s" && continue

  # for each of the expected runs
  for r in 1 2 3 4 5 6 7 8; do
    $scriptdir/03_01_maxFilter.bash $s $r
  done

done
