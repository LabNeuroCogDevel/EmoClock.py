#!/usr/bin/env bash
# create model if we haven't and have FS
# use Clock_make_mne_model.sh
CLOCKDIR="/data/Luna1/Multimodal/Clock"
scriptdir=$(cd $(dirname $0);pwd)
export SUBJECTS_DIR="/data/Luna1/MultiModal/Clock/"
cd $SUBJECTS_DIR
for subj in [1-9]*/; do
  subj=$(basename $subj)
  [ ! -d $SUBJECTS_DIR/$subj/label/ ] && echo "$subj no FS?!" && continue
  [  -r $SUBJECTS_DIR/$subj/bem/$subj-head.fif  ] && echo "$subj already done" && continue
  $scriptdir/Clock_make_mne_model.sh $subj
done
# for each subject
#cd FinalDataDir;

