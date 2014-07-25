#!/usr/bin/env bash
# run  maxfilter  and ICA on those who have all bad channel txt files
CLOCKDIR="/data/Luna1/Multimodal/Clock"
scriptdir=$(cd $(dirname $0);pwd)

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
    badfile="$CLOCKDIR/${s}/MEG/${s}_clock_bad_run${r}.txt"
    finalfile="$CLOCKDIR/${s}/MEG/${s}_clock_run${r}_ds_sss_raw.fif"
         
    # skip if we've already done
    [ -r "$finalfile" ] && echo "already did $s:$r" && continue
    # skip if we don't have the text file
    [ ! -r "$badfile" ] && echo "missing $s:$r txt file" && continue

    echo "running maxfilter on $s $r"
    /neuro/bin/util/i686-pc-linux-gnu/maxfilter-2.2 \
          -f $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_raw.fif \
          -o $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_raw_chpi_sss.fif \
          -origin fit -autobad off \
          -bad $(sed s/MEG// $badfile) \
          -st 10 -movecomp inter -v -force \
          -ctc /data/Luna1/ni_tools/maxfilter_calib/ct_sparse.fif \
          -cal /data/Luna1/ni_tools/maxfilter_calib/sss_cal.dat \
          > $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_sss.log
          
    /neuro/bin/util/i686-pc-linux-gnu/maxfilter-2.2 \
          -f $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_raw_chpi_sss.fif \
          -o $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_ds_sss_raw.fif \
          -origin fit -trans default -frame head -force -v -autobad off -ds 4 \
          > $CLOCKDIR/${s}/MEG/${s}_clock_run${r}_trans.log


  done

  # check that we have all 8 runs
  numMaxFilter=$(ls $CLOCKDIR/${s}/MEG/${s}_clock_run[1-8]_ds_sss_raw.fif 2>/dev/null|wc -l )
  if [ "$numMaxFilter" -eq 8 ]; then
   echo "running ICA on $s $r"
   matlab -nodisplay -r "cd('$scriptdir');pwd, try, Clock_ICA_denoising_wrapper( $s ), catch, fprintf('failed to run ica for $s\n'), end; quit;"
  else 
   echo "$s has only  $numMaxFilter maxfiltered FIFs"
  fi

done
