#!/usr/bin/env bash

# MEG processing is in /data/Luna1/MultiModal/Clock/$SUBJ/MEG/
# link eve and csv there

# where we want eve and csv to go
otherdir="/data/Luna1/MultiModal/Clock/"

# list all the eve and csv files
for f in $(pwd)/subjs/*_*/behavior/*.{eve,csv}; do
  # should have a directory that matches subject_date
  # so we can extract subject (and date, but never used)

  [[ ! $f =~ /([0-9][0-9][0-9][0-9][0-9])_([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])/ ]] && echo "bad name $f" && continue;
  subj=${BASH_REMATCH[1]}
  date=${BASH_REMATCH[2]}

  # make sure we exist in the new place
  newdir=$otherdir/$subj/MEG/
  [ ! -d $newdir ]  && echo "no MEG dir $newdir ($(basename $f)) " && continue

  # already exists, skip
  [ -r $newdir/$(basename $f) ] && continue 

  # link in
  ln -s $f $newdir

done
