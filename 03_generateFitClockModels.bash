#!/usr/bin/env bash

for d in FinalDataDir/1*/; do
  # if we have eve files that do not start with MEG_, we've already run
  # so we should continue
  ls $d/MEG/[^M]*eve 2>/dev/null  1>&2 && continue

  # if we have a skipme file, skip
  ls $d/MEG/skipme* 2>/dev/null  1>&2 && echo "$(basename $d): have skipfile, remove $d/MEG/skipme*!" && continue

  logfile="$d/MEG/Rmodel.log"
  [ -r $logfile ] && echo "$(basename $d): have model file, remove $logfile!" && continue
   
  #otherwise generate the model and save the column vector eve for rpe ev and Reward
  echo  $(basename $d) $d

  cmd="/data/Luna1/ni_tools/R-3.0.2/bin/Rscript -e \"source('saveModel.R');writeEveFromModel(saveModel($(basename $d)))\""
  echo "[$(date)] started: $cmd" > $logfile
  eval $cmd

  # write a failed run file if no eve files
  if ! ls $d/MEG/[^M]*eve 2>/dev/null  1>&2; then
    echo -e "# $(basename $d) $d $(date)\ncd $(pwd)\n$cmd" >> $d/MEG/skipme.failedRun 
    echo "[$(date)] failed: no eve files created" >> $logfile
    continue
  fi

  echo "[$(date)] finished" >> $logfile

done
