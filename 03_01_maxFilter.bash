#!/usr/bin/env bash

# where is maxfilter
PATH="/neuro/bin/util/i686-pc-linux-gnu/:$PATH"
# get functions
scriptdir=$(cd $(dirname $0);pwd)
source $scriptdir/funcs.bash
# log, testnoproc, exiterr
# where are fifs
CLOCKDIR="/data/Luna1/Multimodal/Clock"

s="$1"
[ -z "$s" -o ! -r "$CLOCKDIR/$s" ] && exiterr "need a subject as first argument, see $CLOCKDIR"

r="$2"
[ -z "$r" ] && exiterr "need a run number for subject $s"

sdir="$CLOCKDIR/${s}/MEG"
badfile="$sdir/${s}_clock_bad_run${r}.txt"
finalfile="$sdir/${s}_clock_run${r}_ds_sss_raw.fif"
procfile="$sdir/maxfilter_${r}.log"

     
# skip if we've already done
[ -r "$finalfile" ] && echo "already did $s:$r" && exit 0
# skip if we don't have the text file
[ ! -r "$badfile" ] && exiterr "missing $s:$r bad channel txt file ($badfile)" 

#skip if we started but never finished
testnoproc "$s:$r" "$procfile" "$finalfile" || exit 0

sssfile="$sdir/${s}_clock_run${r}_sss.log"
transfile="$sdir/${s}_clock_run${r}_trans.log"


echo "[$(date +%F\ %H:%M)] running maxfilter on $s $r" | tee $procfile

pattern="${s}_clock_run${r}_raw.fif"
inputfile=$(find $sdir -iname $pattern|tail -n1 )

[ -z "$inputfile" ] && log "$s:$r no raw $sdir/$pattern" $procfile && exit 1

if ! maxfilter-2.2 \
      -f $inputfile \
      -o $sdir/${s}_clock_run${r}_raw_chpi_sss.fif \
      -origin fit -autobad off \
      -bad $(sed 's/MEG//;s/#.*//' $badfile) \
      -st 10 -movecomp inter -v -force \
      -ctc /data/Luna1/ni_tools/maxfilter_calib/ct_sparse.fif \
      -cal /data/Luna1/ni_tools/maxfilter_calib/sss_cal.dat \
      > $sssfile; then

   log "failed to sss $s $r" $procfile
   exit 1
else 
   log "finished sss $s $r" $procfile
fi
      
if ! maxfilter-2.2 \
      -f $sdir/${s}_clock_run${r}_raw_chpi_sss.fif \
      -o $sdir/${s}_clock_run${r}_ds_sss_raw.fif \
      -origin fit -trans default -frame head -force -v -autobad off -ds 4 \
      > $transfile; then

   log "failed to trans $s $r" $procfile
   exit 1
else 
   log "finished trans $s $r" $procfile
fi


[ -r "$transfile" -a -r "$sssfile" ] && \
 log "finished maxfilter on $s $r" $procfile
