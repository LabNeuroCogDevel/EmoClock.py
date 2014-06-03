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

## make CSV/EVE 
# link the fif files from /data/Luna1/MultiModal/MEG_Raw to here
# use timing.py to make csv file
./01_behave2CSV.bash  2>&1 >> log/nightly.log

## link csv/eve to FINAL
#   /data/Luna1/EmoClockMEG --> /data/Luna1/MultiModal/Clock/
./02_linkToMMClock.bash  2>&1 >> log/nightly.log

## link FS to FINAL
# /data/Luna1/MultiModal/FS_Subjects/ --> /data/Luna1/MultiModal/Clock/
./02_linkFStoMM.bash 2>&1 >> log/nightly.log

# print changes to log and update git tracking of log
git diff log/nightly.log  || $( git add log/nightly.log && git commit -m 'nightly update log change')
