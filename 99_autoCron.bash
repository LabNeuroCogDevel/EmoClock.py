#!/usr/bin/env bash
# -- run steps needed to orginize Clock data (imaging and behav)

## the confusing state of file locations:
# -- data
# FS    /data/Luna1/MultiModal/FS_Subjects/ 
# MEG   /data/Luna1/MultiModal/MEG_Raw 
# BHV   B\bea_res\Data\Tasks\EmoClockMEG
# -- organized
# HERE  /data/Luna1/EmoClockMEG
# FINAL /data/Luna1/MultiModal/Clock/

## run from HERE: /data/Luna1/EmoClockMEG
cd $(cd $(dirname $0);pwd)

## get MAT
# retrive the button press timings and conditions (.mat)
# stored on B, mounted on reese
./00_getBehave.bash  2>&1 > log/nightly.log

ls subjs/*/behavior/*.csv | perl -F/ -slane '$_=$F[$#F]; m/\d{5}_\d{8}/; print $&' |sort |uniq -c > log/behavior.txt

## make CSV/EVE 
# link the fif files from /data/Luna1/MultiModal/MEG_Raw to here
# use timing.py to make csv file
./01_behave2CSV.bash  2>&1 >> log/nightly.log

# break up the eve files made above to smaller bits (RT,ITI,clock, and feedback)
./01.2_extractFB+Clock+Rsp_eve.pl 2>&1 >> log/nightly.log

## copy  FIF
# uses behav dir structre to identify lunaid_date to pull
./01_copyRawMEG.bash

## link csv/eve to FINAL
#   /data/Luna1/EmoClockMEG --> /data/Luna1/MultiModal/Clock/
./02_linkToMMClock.bash  2>&1 >> log/nightly.log

## link FS to FINAL
# /data/Luna1/MultiModal/FS_Subjects/ --> /data/Luna1/MultiModal/Clock/
./02_linkFStoMM.bash 2>&1 >> log/nightly.log
# TODO:
# run clock_mne_model.sh if we have FS

# generate R models and column vectors of rpe,ev, and Reward
./03_generateFitClockModels.bash 2>&1 >> log/nightly.log
ls Rprof* 2>/dev/null && mv Rprof* rout # R profile files

# run clock_maxfilter_Scripts if we have 8 text files for the subject
#     clock_ICA_denoise_wrapper w/ fieldtrip in path if we have done max filter
./03_maxFilter_ICA.bash 2>&1 >> log/nightly.log
#TODO:
# mail julia if there are missing text files


# print changes to log and update git tracking of log
git --no-pager  diff --exit-code log/nightly.log || ( git add log/nightly.log && git commit -m 'nightly update log change' && git push)
