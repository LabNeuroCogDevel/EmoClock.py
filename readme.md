# 

## Pipeline

  1. `00_getBehave.bash` (may change permissions, but nondestructive)
     1. finds all matlab files on B
     2. rsyncs them into `subjs/id_date/behavior/*.mat`
  2. `00_behave2CSV.bash` (does not relink, skips `timing.py` if csv exists)
     1. link in the MEG raw fifs to `subjs/id_date/MEG/*fif`
     2. run `timing.py` to generate csv files for the `fitclock` R package

## Structure
```text
  ./
    project root, contains scripts and logs
  
  subjs/id_date/MEG/
    meg fif files, linked from raw location

  subjs/id_date/behavior/
    mat and csv files from behavioral 
```
