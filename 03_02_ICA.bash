#!/usr/bin/env bash

# get functions
scriptdir=$(cd $(dirname $0);pwd)
source $scriptdir/funcs.bash
# log, testnoproc, exiterr
# where are fifs
CLOCKDIR="/data/Luna1/Multimodal/Clock"

s="$1"
[ -z "$s" -o ! -r "$CLOCKDIR/$s" ] && exiterr "need a subject as first argument, see $CLOCKDIR"

#logfile
procfile="$CLOCKDIR/${s}/MEG/ICA.log"

## ICA  -- must have all 8 runs
testnoproc "$s" "$procfile" "$finalfile" || continue
# check that we have all 8 runs
numMaxFilter=$(ls $CLOCKDIR/${s}/MEG/${s}_clock_run[1-8]_ds_sss_raw.fif 2>/dev/null|wc -l )

if [ "$numMaxFilter" -eq 8 ]; then
 #[ -r "$procifle" ] && rm $procfile
 log "starting ICA on $s (runs 1-8)" $procfile

 matlab -nodisplay -r \
  "cd('$scriptdir');pwd, try, Clock_ICA_denoising_wrapper( $s ), catch, fprintf('failed to run ica for $s\n'), end; quit;"

 log "finished ICA on $s $r" $procfile
else 
 log "$s has only  $numMaxFilter maxfiltered FIFs" | tee -a $procifle
fi
