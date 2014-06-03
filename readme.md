# 

## Data Paths

 | data  | location |
 |-------|---------------------------------------|
 | MEG   | `/data/Luna1/MultiModal/MEG_Raw`      |
 | BHV   | `B\bea_res\Data\Tasks\EmoClockMEG`    |
 | HERE  | `/data/Luna1/EmoClockMEG`             |
 | FINAL | `/data/Luna1/MultiModal/Clock`        |

## Pipeline

see `99_autoCron.bash` for nightly execution

  1. `00_getBehave.bash` (may change permissions, but nondestructive)
     1. finds all matlab files on B
     2. rsyncs them into `subjs/id_date/behavior/*.mat`
  1. `01_behave2CSV.bash` (does not relink, skips `timing.py` if csv and eve exist)
     1. link in the MEG raw fifs to `subjs/id_date/MEG/*fif`
     2. run `timing.py` to generate csv files for the `fitclock` R package
     3. also create eve event files for MNE 
  1. `02_linkToMMClock.bash` 
     1. link csv/eve to FINAL
  1. `02_linkFStoMM.bash` 
     1. link FS to FINAL

## Structure
```text
  ./
    project root, contains scripts and logs
  
  subjs/id_date/MEG/
    meg fif files, linked from raw location

  subjs/id_date/behavior/
    mat and csv files from behavioral 
```

## FS
see `/home/foranw/src/freesurfersearcher-general/need`
